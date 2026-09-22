const API_URL = "";


async function loadPhotos() {
    const response = await fetch(`${API_URL}/api/photos`);

    const data = await response.json();

    const gallery = document.getElementById("gallery");

    gallery.innerHTML = "";

    data.photos.forEach(photo => {

        const card = document.createElement("div");

        card.className = "photo-card";

        card.innerHTML = `
            <img src="${photo.url}" alt="photo">
        `;

        gallery.appendChild(card);
    });
}


async function uploadPhoto() {

    const input = document.getElementById("photoInput");

    if (!input.files.length) {
        return;
    }

    const formData = new FormData();

    formData.append("file", input.files[0]);

    await fetch(`${API_URL}/api/photos`, {
        method: "POST",
        body: formData
    });

    loadPhotos();
}



loadPhotos();
