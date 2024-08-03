export let NoteCreator = {
  line() { return this.el.dataset.line },
  mounted() {
    console.log('[NoteCreator] mounted...')
    // TODO: add a toolbar div with id 
    new Quill("#note-creator", {
      modules: {
        toolbar: false,
      },
      theme: 'snow'
    });
    window.addEventListener("codejam:create-editor", e => {
      console.log('codejam:create-editor',e.target.id, this.line())
  
      const editorInstance = Quill.find(document.getElementById(e.target.id));
      console.log(editorInstance.getSemanticHTML())
      this.pushEvent("add-note-creator", {
        content: editorInstance.getSemanticHTML(),
        line: this.line()
      });
    })
  },
  updated() {
    console.log('[NoteCreator] updated...')
    new Quill("#note-creator", {
      modules: {
        toolbar: false,
      },
      theme: 'snow'
    });
  }
}