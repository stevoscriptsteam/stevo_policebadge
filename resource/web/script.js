function showBadge(data) {
    document.body.style.display = 'inline';
    document.getElementById('name').innerText = `${data.name}`;
    document.getElementById('rank').innerText = `${data.rank}`;
    
    if (data.photo) {
        document.getElementById('background-img').src = data.photo;
    } else {
        document.getElementById('background-img').src = 'img/none.png';
    }
    setTimeout(() => {
        document.body.style.display = 'none';
    }, 5000);
}

window.addEventListener('message', function(event) {
    if (event.data && event.data.type === "displayBadge" && event.data.data) {
        showBadge(event.data.data);
    }
});
