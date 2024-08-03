export let NoteEditor = {
  noteid() { return this.el.dataset.noteid },
  mounted() {
    console.log('[NoteEditor] mounted...')
    // TODO: add a toolbar div with id 
    new Quill("#note-editor", {
      modules: {
        toolbar: false,
      },
      theme: 'snow'
    });
    window.addEventListener("codejam:edit-editor", e => {
      console.log('codejam:edit-editor',e.target.id, this.noteid())
  
      const editorInstance = Quill.find(document.getElementById(e.target.id));
      console.log(editorInstance.getSemanticHTML())
      this.pushEvent("add-note-editor", {
        content: editorInstance.getSemanticHTML(),
        noteid: this.noteid()
      });
    })
  },
  updated() {
    console.log('[NoteEditor] updated...')
    new Quill("#note-editor", {
      modules: {
        toolbar: false,
      },
      theme: 'snow'
    });
  }
}