import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/export_list.dart';
import '../../domain/entities/operation.dart';

/// T-127 · Cómo viaja una fuente de la operación por la nube: su huella, sus
/// trozos y, para el listado, su revisión (T-79a 5.1; 10.78).
///
/// - Al publicar, cada fuente va en trozos `{tipo}-{i}`, cada uno con la
///   huella SHA-256 del texto entero, y el manifiesto `sources.{tipo}` de la
///   operación dice cuántos son (T-79, 10.11). Esos trozos no cambian.
/// - Desde T-127 la oficina puede agregar o reemplazar el **listado** de una
///   operación publicada mientras siga abierta: los trozos nuevos se llaman
///   `export_list-r{n}-{i}` y llevan `revision: n`, y la entrada
///   `sources.export_list` del manifiesto suma `revision: n`. Los trozos de
///   las revisiones anteriores quedan (las reglas no dejan borrarlos ni
///   editarlos): quien lee se queda solo con los de la revisión que el
///   manifiesto declara. Los BAPLIE siguen inmutables, porque son el contrato
///   de las claves naturales de los movimientos.
///
/// Dart puro: lo usan el adaptador de Firestore (`publish`, `join` y
/// `replaceSource`) y el motor (`follow`), y la nube falsa de las pruebas.

/// Trozo de una fuente: 300 000 caracteres son a lo sumo 900 000 bytes en
/// UTF-8, dentro del MiB por documento y de las 900 000 de las reglas.
const sourcePartLength = 300000;

/// Huella SHA-256 del texto en UTF-8, tal cual (10.11).
String sourceHash(String content) =>
    sha256.convert(utf8.encode(content)).toString();

/// Parte el texto sin cortar un par sustituto de UTF-16.
List<String> splitSource(String content, [int length = sourcePartLength]) {
  if (content.isEmpty) return [''];
  final parts = <String>[];
  var start = 0;
  while (start < content.length) {
    var end = start + length;
    if (end >= content.length) {
      end = content.length;
    } else if (_isHighSurrogate(content.codeUnitAt(end - 1))) {
      end--;
    }
    parts.add(content.substring(start, end));
    start = end;
  }
  return parts;
}

bool _isHighSurrogate(int unit) => unit >= 0xD800 && unit <= 0xDBFF;

/// Id del documento de un trozo: `loading_baplie-0` al publicar, o
/// `export_list-r2-0` para la revisión 2 del listado.
String sourcePartId(OperationSourceKind kind, int part, {int? revision}) =>
    revision == null ? '${kind.wire}-$part' : '${kind.wire}-r$revision-$part';

/// La entrada de una fuente en el manifiesto `sources` de la operación.
class SourceManifestEntry extends Equatable {
  final OperationSourceKind kind;
  final String fileName;

  /// Huella del texto entero.
  final String sha256;
  final int parts;

  /// Caracteres del texto.
  final int length;

  /// Solo el listado, y solo si la oficina lo agregó o lo reemplazó después
  /// de publicar: 1, 2, 3… Nula en lo publicado con la operación.
  final int? revision;

  const SourceManifestEntry({
    required this.kind,
    required this.fileName,
    required this.sha256,
    required this.parts,
    required this.length,
    this.revision,
  });

  /// Lo que se escribe en el manifiesto.
  Map<String, Object?> toMap() => {
        'fileName': fileName,
        'sha256': sha256,
        'parts': parts,
        'length': length,
        if (revision != null) 'revision': revision,
      };

  /// Lee la entrada de [kind]; null si no es un mapa con sus campos.
  static SourceManifestEntry? read(OperationSourceKind kind, Object? entry) {
    if (entry is! Map) return null;
    final parts = entry['parts'];
    final sha = entry['sha256'];
    if (parts is! num || sha is! String) return null;
    final revision = entry['revision'];
    return SourceManifestEntry(
      kind: kind,
      fileName: entry['fileName'] as String? ?? kind.wire,
      sha256: sha,
      parts: parts.toInt(),
      length: (entry['length'] as num?)?.toInt() ?? 0,
      revision: revision is num ? revision.toInt() : null,
    );
  }

  @override
  List<Object?> get props => [kind, fileName, sha256, parts, length, revision];
}

/// Un trozo de una fuente, como documento de `operations/{id}/sources/`.
class SourcePart extends Equatable {
  final String id;
  final OperationSourceKind kind;
  final int part;
  final int parts;

  /// Huella del texto entero, la misma en todos los trozos y en el manifiesto.
  final String sha256;
  final String content;
  final int? revision;

  const SourcePart({
    required this.id,
    required this.kind,
    required this.part,
    required this.parts,
    required this.sha256,
    required this.content,
    this.revision,
  });

  /// El documento, sin `createdBy` ni `createdAt`, que pone quien escribe.
  Map<String, Object?> toMap() => {
        'id': id,
        'kind': kind.wire,
        'sha256': sha256,
        'part': part,
        'parts': parts,
        'content': content,
        if (revision != null) 'revision': revision,
      };

  /// Lee un documento; null si no se entiende, y entonces no cuenta.
  static SourcePart? read(Map<String, dynamic>? data) {
    if (data == null) return null;
    OperationSourceKind? kind;
    for (final k in OperationSourceKind.values) {
      if (k.wire == data['kind']) kind = k;
    }
    final part = data['part'];
    final parts = data['parts'];
    final sha = data['sha256'];
    final content = data['content'];
    if (kind == null ||
        part is! num ||
        parts is! num ||
        sha is! String ||
        content is! String) {
      return null;
    }
    final revision = data['revision'];
    return SourcePart(
      id: data['id'] as String? ?? '',
      kind: kind,
      part: part.toInt(),
      parts: parts.toInt(),
      sha256: sha,
      content: content,
      revision: revision is num ? revision.toInt() : null,
    );
  }

  @override
  List<Object?> get props => [id, kind, part, parts, sha256, content, revision];
}

/// Los trozos de [source], con la huella del texto entero en cada uno, y su
/// entrada del manifiesto. Con [revision], los de una revisión del listado.
({SourceManifestEntry entry, List<SourcePart> parts}) packSource(
    OperationSource source,
    {int? revision}) {
  final pieces = splitSource(source.content);
  final hash = sourceHash(source.content);
  return (
    entry: SourceManifestEntry(
      kind: source.kind,
      fileName: source.fileName,
      sha256: hash,
      parts: pieces.length,
      length: source.content.length,
      revision: revision,
    ),
    parts: [
      for (var i = 0; i < pieces.length; i++)
        SourcePart(
          id: sourcePartId(source.kind, i, revision: revision),
          kind: source.kind,
          part: i,
          parts: pieces.length,
          sha256: hash,
          content: pieces[i],
          revision: revision,
        ),
    ],
  );
}

/// Une los trozos de la fuente que [entry] declara, de entre [parts]: los de
/// su tipo y su revisión (sin revisión, los publicados con la operación; con
/// ella, solo los de esa revisión, aunque queden los de las anteriores). La
/// huella se calcula sobre el texto tal como se publicó (10.11): no se
/// vuelve a serializar nada antes de comprobarla. Null si faltan trozos o
/// alguna huella no es la del manifiesto: `join` rechaza la operación entera
/// (`source_mismatch`) y el muelle que la sigue se queda con el listado que
/// tenía.
OperationSource? assembleSource(
    SourceManifestEntry entry, Iterable<SourcePart> parts) {
  final pieces = [
    for (final p in parts)
      if (p.kind == entry.kind && p.revision == entry.revision) p
  ]..sort((a, b) => a.part.compareTo(b.part));
  if (pieces.length != entry.parts) return null;
  for (var i = 0; i < pieces.length; i++) {
    if (pieces[i].part != i || pieces[i].sha256 != entry.sha256) return null;
  }
  final content = pieces.map((p) => p.content).join();
  if (sourceHash(content) != entry.sha256) return null;
  return OperationSource(
      kind: entry.kind,
      fileName: entry.fileName,
      content: content,
      revision: entry.revision);
}

/// Cuántas filas trae un listado publicado (el JSON de `ExportList`); null
/// si el texto no es un listado que esta versión de la app lea.
int? exportListRows(String content) {
  try {
    return ExportList.fromJson(jsonDecode(content) as Map<String, dynamic>)
        .rows
        .length;
  } catch (_) {
    return null;
  }
}
