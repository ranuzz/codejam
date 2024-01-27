export let NoteEditor = {
  line() { return this.el.dataset.line },
  mounted() {
    console.log('[NoteEditor] mounted...')
    // TODO: add a toolbar div with id 
    new Quill(`#inode-note-${this.line()}-editor`, {
      modules: {
        toolbar: false,
      },
      theme: 'snow'
    });
    window.addEventListener(`codejam:save-editor-${this.line()}`, e => {
      console.log('codejam:save-editor',e.target.id, this.line())
  
      const editorInstance = Quill.find(document.getElementById(e.target.id));
      console.log(editorInstance.getText())
      this.pushEvent("add-note-editor", {
        content: editorInstance.getText(),
        line: this.line()
      });
    })
  },
  updated() {
    console.log('[NoteEditor] updated...')
    new Quill(`#inode-note-${this.line()}-editor`, {
      modules: {
        toolbar: false,
      },
      theme: 'snow'
    });
  }
}