function deleteProject(url) {
    console.log("this was called!")
    fetch(url, { method: 'DELETE' }).then(() => {
        window.location.reload()
    })
}