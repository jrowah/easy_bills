let ItemHooks = {}

ItemHooks.ItemsContainer = {
  mounted() {
    const template = document.getElementById('new-item')
    const addButton = document.getElementById('add-item-button')
    const tableBody = document.getElementById('table-items-body')

    addButton.addEventListener('click', () => {
      if ('content' in document.createElement('template')) {
        const row = template.content.cloneNode(true).querySelector('tr')
        tableBody.appendChild(row)
        this.attachDeleteEvent(row)
      }
    })

    tableBody.querySelectorAll('.delete-item').forEach((icon) => {
      this.attachDeleteEvent(icon)
    })
  },

  attachDeleteEvent(element) {
    let deleteIcon = element.querySelector('.delete-item')

    if (deleteIcon) {
      deleteIcon.addEventListener('click', (event) => {
        event.preventDefault()
        event.stopPropagation()
        let rowToDelete = event.target.closest('tr')

        if (rowToDelete) {
          rowToDelete.remove()
        }
      })
    }
  },
}

export default ItemHooks
