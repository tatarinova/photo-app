const API_URL = "http://localhost:8000";


async function loadPhotos() {
    const response = await fetch(`${API_URL}/photos`);

    const data = await response.json();

    const gallery = document.getElementById("gallery");

    gallery.innerHTML = "";

    data.photos.forEach(filename => {

        const card = document.createElement("div");

        card.className = "photo-card";

        card.innerHTML = `
            <img src="${API_URL}/uploads/${filename}" alt="${filename}">
            <p>${filename}</p>
            <button onclick="deletePhoto('${filename}')">
                Delete
            </button>
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

    await fetch(`${API_URL}/photos`, {
        method: "POST",
        body: formData
    });

    loadPhotos();
}


async function deletePhoto(filename) {

    await fetch(`${API_URL}/photos/${filename}`, {
        method: "DELETE"
    });

    loadPhotos();
}


loadPhotos();
