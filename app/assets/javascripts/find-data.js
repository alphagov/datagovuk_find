function sortDatasets() {
    document.location.href = newLocation()

    function newLocation() {
        var currentLocation = document.location.href
        var sortParam = "&sort="
        var sortQuery = sortParam + document.getElementById("sort-datasets").value

        return currentLocation.indexOf(sortParam) ===  -1
            ? currentLocation + sortQuery
            : currentLocation.replace(/&sort=[\w]+/, sortQuery)
    }
}
