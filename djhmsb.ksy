meta:
  id: djhmsb
  file-extension: djhmsb
  endian: be
  file-extension: "msb"
doc: |
   DJ Hero Model
seq:
  - id: header
    type: header
  - id: block
    type: block
    repeat: eos
types:
  header:
    seq:
      - id: magic
        contents: "FSG*"
      - id: filesize
        type: u4
      - id: console
        type: str
        size: 4
        encoding: "UTF-8"
      - id: unk_2
        type: u4
      - id: unk_3
        type: u4
      - id: unk_4
        type: u4
      - id: unk_5
        type: u4
      - id: main_data_size
        type: u4
  block:
    seq:
      - id: block_type
        type: u4
        enum: block_types
      - id: contents_size
        type: u4
      - id: block_size
        type: u4
      - id: padding_header
        size: 20
      - id: block_data
        type:
          switch-on: block_type
          cases:
            'block_types::unk_1': block_unk
            'block_types::texture_files' : block_text
            'block_types::shader_files' : block_text
            'block_types::model_data' : block_model_data
            _: block_unk
        size: contents_size
      - id: padding_data
        size: block_size - contents_size
    -webide-representation: '{block_type}'
  block_unk:
    seq:
      - id: data_unk
        size: _parent.contents_size
  block_text:
    seq:
      - id: string_count
        type: u4
      - id: string_with_len
        type: string_with_len
        repeat: expr
        repeat-expr: string_count
  string_with_len:
    seq:
      - id: string_length
        type: u4
      - id: string_data
        type: str
        encoding: "UTF-8"
        size: string_length
    -webide-representation: '{string_data}'
  block_model_data:
    seq:
      - id: model_type
        type: u2
        enum: console_types
      - id: unk_type
        type: u2
      - id: model_console_data
        type:
          switch-on: model_type
          cases:
            'console_types::ps3' : block_model_unk
            'console_types::xbox' : block_model_xbox
            'console_types::wii' : block_model_unk
            _: block_model_unk
    -webide-representation: '{model_type}'
  block_model_unk:
    seq:
      - id: unk_int
        type: u4
      - id: unk_int2
        type: u4
      - id: unk_int3
        type: u4
      - id: model_bones_count
        type: u4
      - id: faces_bytes
        type: u4
      - id: vertex_bytes
        type: u4
      - id: matatlas_count
        type: u2
      - id: texatlas_count
        type: u2
  block_model_xbox:
    seq:
      - id: unk_int
        type: u4
      - id: unk_int2
        type: u4
      - id: unk_int3
        type: u4
      - id: model_bones_count
        type: u4
      - id: faces_bytes
        type: u4
      - id: vertex_bytes
        type: u4
      - id: matatlas_count
        type: u4
      - id: texatlas_count
        type: u4
      - id: unk_stuff
        size: 72
      - id: tex_atlases
        type: model_texatlas
        repeat: expr
        repeat-expr: texatlas_count
      - id: mat_atlases
        type: model_matatlas
        repeat: expr
        repeat-expr: matatlas_count
      - id: mesh_count
        type: u4
      - id: meshes
        type: mesh
        repeat: expr
        repeat-expr: mesh_count
      - id: model_bones
        type: model_bone
        repeat: expr
        repeat-expr: model_bones_count
      - id: faces_blob
        type: blob
        size: faces_bytes
      - id: vertices_blob
        type: blob
        size: vertex_bytes
      # - id: faces
      #   type: model_face
      #   size: faces_bytes / 6
      # - id: vertices
      #   type: model_vertex
      #   repeat: expr
      #   repeat-expr: vertex_bytes / 72
      # - id: vertices_extra
      #   type: f4
      #   repeat: expr
      #   repeat-expr: (vertex_bytes % 24) / 4
  model_texatlas:
    seq:
      - id: unk
        size: 276
  model_matatlas:
    seq:
      - id: unk
        size: 312
  mesh:
    seq:
      - id: unk_1
        type: u4
      - id: face_count
        type: u4
      - id: vertex_count
        type: u4
      - id: vertex_unk0_count
        type: b4
      - id: vertex_unk1_count
        type: b4
      - id: vertex_uvs_count
        type: b4
      - id: vertex_unk2_count
        type: b4
      - id: vertex_unk3
        type: u2
      - id: face_offset
        type: u4
      - id: vertex_offset
        type: u4
      - id: material_index
        type: u4
    instances:
      faces:
        io: _parent.faces_blob._io
        pos: face_offset * 2
        type: model_face
        # size: face_count * 6
        repeat: expr
        repeat-expr: face_count
      vertices:
        io: _parent.vertices_blob._io
        pos: vertex_offset * vertex_bytes
        type: model_vertex
        repeat: expr
        repeat-expr: vertex_count
      vertex_bytes:
        value: 12 + vertex_unk1_count * 12 + 12
          + vertex_uvs_count * 8 + 12
  model_bone:
    seq:
      - id: unk
        size: 176
  model_face:
    seq:
      - id: vertex1
        type: u2
      - id: vertex2
        type: u2
      - id: vertex3
        type: u2
  model_vertex_xyz:
    seq:
    - id: x
      type: f4
    - id: y
      type: f4
    - id: z
      type: f4
  model_vertex_unk:
    seq:
    - id: unk1
      type: u4
    - id: unk2
      type: u4
    - id: unk3
      type: u4
  model_vertex_uv:
    seq:
      - id: u
        type: f4
      - id: v
        type: f4
  model_vertex:
    seq:
      - id: pos_xyz
        type: model_vertex_xyz
      - id: unk1
        type: model_vertex_unk
        repeat: expr
        repeat-expr: _parent.vertex_unk1_count
      - id: norm_xyz
        type: model_vertex_xyz
      - id: uvs
        type: model_vertex_uv
        repeat: expr
        repeat-expr: _parent.vertex_uvs_count
      - id: unk2_xyz
        type: model_vertex_xyz
  blob:
    seq:
      - id: blob
        size: 0
enums:
  block_types:
    1: unk_1
    3: texture_files
    4: shader_files
    6: model_data
  console_types:
    0x5033: ps3
    0xb0fe: xbox
    0x5749: wii