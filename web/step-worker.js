// STEP / STP reader. Runs OpenCASCADE (occt-import-js, WebAssembly) off the UI thread so the window stays responsive.
// Messages in : {id, cmd:'mesh', fid, buffer?, params}   (buffer only the first time for a file; the worker keeps it so that
//               changing the detail level can re-triangulate without sending the file again)
// Messages out: {id, root, meshes:[{name, color, faces, position, normal, index}]} | {id, error}
importScripts('occt-import-js.js');

let occtP = null, src = null, srcFid = -1;

onmessage = async ev => {
  const m = ev.data;
  try {
    if (m.buffer) {src = new Uint8Array(m.buffer); srcFid = m.fid}
    if (!src || srcFid !== m.fid) throw new Error('STEP source is not loaded');
    if (!occtP) occtP = occtimportjs({locateFile: p => p});
    const occt = await occtP;
    const r = occt.ReadStepFile(src, m.params || null);
    if (!r || !r.success) throw new Error('The STEP file could not be read (unsupported or damaged file).');
    // the library returns plain arrays: convert to typed arrays and hand them over without copying
    const meshes = (r.meshes || []).map(x => ({
      name: x.name || '',
      color: x.color || null,
      faces: (x.brep_faces || []).map(f => ({first: f.first, last: f.last, color: f.color || null})),
      position: Float32Array.from(x.attributes.position.array),
      normal: x.attributes.normal ? Float32Array.from(x.attributes.normal.array) : null,
      index: Uint32Array.from(x.index.array)
    }));
    const tr = [];
    meshes.forEach(x => {tr.push(x.position.buffer, x.index.buffer); if (x.normal) tr.push(x.normal.buffer)});
    postMessage({id: m.id, root: r.root, meshes}, tr);
  } catch (e) {
    occtP = null; // a crashed WebAssembly module cannot be reused
    postMessage({id: m.id, error: String((e && e.message) || e)});
  }
};
