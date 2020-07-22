let fetchedDataFromApi = {
  name: "Ankur",
  description: "Web Developer and an AI enthusiast",
  skills: ["HTML", "CSS", "Python", "react", "Nodejs"],
  interest: ["swiming", "coding", "cooking"],
  achievement: ["Achievement1", "Achievement2", "Achievement3", "Achievement4", "Achievement5", "Achievement6", ],
};
console.log(fetchedDataFromApi);

document.getElementById("ProfileName").innerHTML = fetchedDataFromApi.name;

document.getElementById("ProfileDescription").innerHTML =
  fetchedDataFromApi.description;

const badgeColour = ["success", "danger", "warning", "info", "light", "dark"];

fetchedDataFromApi.skills.map((item) => {
  const badge = `<span id = "skillBadge" class ='badge badge-pill badge-${
    badgeColour[Math.floor(Math.random() * Math.floor(5))]
  }'> ${item} </span>`;
  const ele = document.createElement("div");
  ele.innerHTML = badge;
  //  document.getElementById('s').innerHTML = badge
  document.getElementById("skill").appendChild(ele.firstChild);
});

fetchedDataFromApi.interest.map((item) => {
  const badge = `<span id = "skillBadge" class ='badge badge-pill badge-${
    badgeColour[Math.floor(Math.random() * Math.floor(5))]
  }'> ${item} </span>`;
  const ele = document.createElement("div");
  ele.innerHTML = badge;
  //  document.getElementById('s').innerHTML = badge
  document.getElementById("interest").appendChild(ele.firstChild);
});



for (let i =0; i <= fetchedDataFromApi.achievement.length - 1; i+=3){
    console.log(fetchedDataFromApi.achievement[i])
    const achievementCard = `<div class="card-group">  
      <div class="card mb-3" style="max-width: 400px; margin-left:3rem; margin-bottom: 2rem">
      <div class="row no-gutters">
        <div class="col-md-4">
          <img src="..." class="card-img" alt="...">
        </div>
        <div class="col-md-8">
          <div class="card-body">
            <h5 class="card-title">${fetchedDataFromApi.achievement[i]}</h5>
          </div>
        </div>
      </div>
    </div>

    <div class="card mb-3" style="max-width: 400px; margin-left:3rem; margin-bottom: 2rem">
      <div class="row no-gutters">
        <div class="col-md-4">
          <img src="..." class="card-img" alt="...">
        </div>
        <div class="col-md-8">
          <div class="card-body">
            <h5 class="card-title">${fetchedDataFromApi.achievement[i + 1]}</h5>
          </div>
        </div>
      </div>
    </div>
    <div class="card mb-3" style="max-width: 400px; margin-left:3rem; margin-bottom: 2rem">
      <div class="row no-gutters">
        <div class="col-md-4">
          <img src="..." class="card-img" alt="...">
        </div>
        <div class="col-md-8">
          <div class="card-body">
            <h5 class="card-title">${fetchedDataFromApi.achievement[i + 2]}</h5>
          </div>
        </div>
      </div>
    </div>

</div>`;
  const ele = document.createElement("div");
  ele.innerHTML = achievementCard;
  document.getElementById("Achievement").appendChild(ele.firstChild);


}

    // console.log(item)
  