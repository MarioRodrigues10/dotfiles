function compareSeason(a, b) {
    const seasons = ["winter", "spring", "summer", "fall"]
    if (a === "") return 1
    if (b === "") return -1
    const [aseason, ayear] = a.split(" ")
    const [bseason, byear] = b.split(" ")
    if (ayear < byear) return 1
    if (ayear > byear) return -1
    if (seasons.indexOf(aseason.toLowerCase()) < seasons.indexOf(bseason.toLowerCase()))
        return 1
    if (seasons.indexOf(aseason.toLowerCase()) > seasons.indexOf(bseason.toLowerCase()))
        return -1
    return 0
}

function compareListItem(a, b) {
    const aseason = a.querySelector("td.season").textContent.trim()
    const bseason = b.querySelector("td.season").textContent.trim()
    return compareSeason(aseason, bseason)
}

function appendToTable(listItem) {
    document.querySelector(".list-table").append(listItem)
}

Array.from(document.querySelectorAll(".list-item"))
    .sort(compareListItem)
    .forEach(appendToTable)
