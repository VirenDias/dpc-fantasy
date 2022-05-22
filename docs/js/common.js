// Set theme
var html = document.querySelector("html");
var themeButton = document.querySelector("#theme-button");
var lightIcon = "<i class='bi bi-brightness-high-fill'></i>";
var darkIcon = "<i class='bi bi-brightness-low-fill'></i>";

if (localStorage.getItem('theme')) {
  switch (localStorage.getItem('theme')) {
    case "light":
      themeButton.innerHTML = darkIcon;
      html.setAttribute("theme", "light");
      break;
    case "dark":
      themeButton.innerHTML = lightIcon;
      html.setAttribute("theme", "dark");
      break;
  }
} else if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
  themeButton.innerHTML = lightIcon;
  html.setAttribute("theme", "dark");
  localStorage.setItem("theme", "dark");
} else {
  themeButton.innerHTML = darkIcon;
  html.setAttribute("theme", "light");
  localStorage.setItem("theme", "light");
}

themeButton.addEventListener("click", function() {
  currentTheme = document.querySelector("html").getAttribute("theme");
  switch (currentTheme) {
    case "light":
      themeButton.innerHTML = lightIcon;
      html.setAttribute("theme", "dark");
      localStorage.setItem("theme", "dark");
      break;
    case "dark":
      themeButton.innerHTML = darkIcon;
      html.setAttribute("theme", "light");
      localStorage.setItem("theme", "light");
      break;
  }
});
