/* =========================================
   CUSTOMER / WORKER REGISTRATION
========================================= */

const registerForm = document.getElementById("registerForm");

if (registerForm) {
  const roleOptions = document.querySelectorAll(".role-option");

  const roleInputs = document.querySelectorAll('input[name="role"]');

  /* -----------------------------------------
       ROLE SELECTION
    ----------------------------------------- */

  roleInputs.forEach((input) => {
    input.addEventListener("change", () => {
      roleOptions.forEach((option) => {
        option.classList.remove("selected");
      });

      input.closest(".role-option").classList.add("selected");
    });
  });

  /* -----------------------------------------
       REGISTRATION FORM
    ----------------------------------------- */

  registerForm.addEventListener("submit", (event) => {
    event.preventDefault();

    const name = document.getElementById("name").value.trim();

    const email = document.getElementById("email").value.trim();

    const phone = document.getElementById("phone").value.trim();

    const address = document.getElementById("address").value.trim();

    const city = document.getElementById("city").value.trim();

    const password = document.getElementById("password").value;

    const confirmPassword = document.getElementById("confirmPassword").value;

    /* Get selected role */

    const selectedRole = document.querySelector('input[name="role"]:checked');

    const message = document.getElementById("registerMessage");

    /* -----------------------------------------
           VALIDATION
        ----------------------------------------- */

    if (!selectedRole) {
      message.textContent = "Please select a registration role.";

      message.className = "form-message error";

      return;
    }

    if (password.length < 6) {
      message.textContent = "Password must contain at least 6 characters.";

      message.className = "form-message error";

      return;
    }

    if (password !== confirmPassword) {
      message.textContent = "Passwords do not match.";

      message.className = "form-message error";

      return;
    }

    /* -----------------------------------------
           TEMPORARY REGISTRATION DATA
           Backend will replace this later.
        ----------------------------------------- */

    const registrationData = {
      name: name,

      email: email,

      phone: phone,

      role: selectedRole.value,

      address: address,

      city: city,
    };

    console.log("Registration Data:", registrationData);

    /* -----------------------------------------
           TEMPORARY SUCCESS MESSAGE
        ----------------------------------------- */

    message.textContent = `${selectedRole.value} registration form is valid. Backend connection will be added later.`;

    message.className = "form-message success";
  });
}
/* =========================================
   LOGIN
========================================= */

const loginForm = document.getElementById("loginForm");

if (loginForm) {

    loginForm.addEventListener("submit", (event) => {

        event.preventDefault();

        const email =
            document.getElementById("loginEmail").value.trim();

        const password =
            document.getElementById("loginPassword").value;

        const role =
            document.getElementById("loginRole").value;

        const message =
            document.getElementById("loginMessage");


        /* -----------------------------------------
           VALIDATION
        ----------------------------------------- */

        if (!email || !password || !role) {

            message.textContent =
                "Please fill in all fields.";

            message.className =
                "form-message error";

            return;
        }


        /* -----------------------------------------
           TEMPORARY FRONTEND LOGIN
           Backend will replace this later.
        ----------------------------------------- */

        console.log("Login:", {
            email,
            role
        });


        message.textContent =
            `Login successful as ${role}.`;

        message.className =
            "form-message success";


        /* -----------------------------------------
           TEMPORARY DASHBOARD REDIRECTION
        ----------------------------------------- */

        setTimeout(() => {

            if (role === "CUSTOMER") {

                window.location.href =
                    "customer/dashboard.html";

            } else if (role === "WORKER") {

                window.location.href =
                    "worker/dashboard.html";

            } else if (role === "ADMIN") {

                window.location.href =
                    "admin/dashboard.html";

            }

        }, 800);

    });

}
/* ================= PAGE NAVIGATION ================= */

function showPage(pageId, element){

    let pages =
        document.querySelectorAll(".page");

    pages.forEach(function(page){

        page.classList.remove("active");

    });


    document
        .getElementById(pageId)
        .classList.add("active");


    let menus =
        document.querySelectorAll(".menu");

    menus.forEach(function(menu){

        menu.classList.remove("active");

    });


    element.classList.add("active");

}


/* ================= REGISTRATION ================= */

function registerWorker(){

    let name =
        document.getElementById("regName").value;

    let phone =
        document.getElementById("regPhone").value;

    let email =
        document.getElementById("regEmail").value;

    let area =
        document.getElementById("regArea").value;


    if(
        name === "" ||
        phone === "" ||
        email === "" ||
        area === ""
    ){

        alert(
            "Please fill all required fields."
        );

        return;

    }


    document.getElementById(
        "profileName"
    ).value = name;


    document.getElementById(
        "profileDisplayName"
    ).innerText = name;


    alert(
        "Worker Registration Submitted Successfully!\n\n" +
        "Status: Pending Verification"
    );

}


/* ================= PROFILE ================= */

function saveProfile(){

    let name =
        document.getElementById("profileName").value;


    if(name !== ""){

        document.getElementById(
            "profileDisplayName"
        ).innerText = name;

    }


    alert(
        "Worker Profile Updated Successfully! ✅"
    );

}


/* ================= DOCUMENT ================= */

function uploadDocument(){

    let file =
        document.getElementById(
            "documentFile"
        ).files[0];


    if(!file){

        alert(
            "Please select a document first."
        );

        return;

    }


    alert(
        "Document uploaded successfully!\n" +
        "Status: Pending Verification"
    );

}


/* ================= ACCEPT JOB ================= */

function acceptJob(){

    let status =
        document.getElementById(
            "requestStatus"
        );


    status.innerText = "Accepted";

    status.className =
        "status accepted";


    alert(
        "Job Accepted Successfully! ✅"
    );

}


/* ================= REJECT JOB ================= */

function rejectJob(){

    let status =
        document.getElementById(
            "requestStatus"
        );


    status.innerText = "Rejected";

    status.className =
        "status rejected";


    alert(
        "Job Request Rejected."
    );

}


/* ================= APPLY JOB ================= */

function applyJob(jobName){

    let confirmApply =
        confirm(
            "Do you want to apply for " +
            jobName + "?"
        );


    if(confirmApply){

        let count =
            document.getElementById(
                "pendingJobs"
            );


        count.innerText =
            parseInt(count.innerText) + 1;


        alert(
            "Application submitted successfully! ✅"
        );

    }

}


/* ================= START JOB ================= */

function startJob(){

    document.getElementById(
        "stepProgress"
    ).classList.add("active");


    alert(
        "Job status updated to In Progress."
    );

}


/* ================= COMPLETE JOB ================= */

function completeJob(){

    document.getElementById(
        "stepCompleted"
    ).classList.add("active");


    alert(
        "Job marked as Completed! ✅"
    );

}


/* ================= AVAILABILITY ================= */

function toggleAvailability(){

    let switchElement =
        document.getElementById(
            "availabilitySwitch"
        );


    let text =
        document.getElementById(
            "availabilityText"
        );


    let sideText =
        document.getElementById(
            "sideAvailability"
        );


    switchElement.classList.toggle("active");


    if(
        switchElement.classList.contains("active")
    ){

        text.innerText = "Available";

        sideText.innerText =
            "Available for Work";

    }
    else{

        text.innerText = "Unavailable";

        sideText.innerText =
            "Unavailable";

    }

}


/* ================= WORKING HOURS ================= */

function saveHours(){

    alert(
        "Working hours saved successfully! ✅"
    );

}


/* ================= SEARCH JOBS ================= */

function searchJobs(){

    let search =
        document.getElementById(
            "searchJob"
        ).value.toLowerCase();


    let skill =
        document.getElementById(
            "skillFilter"
        ).value.toLowerCase();


    let location =
        document.getElementById(
            "locationFilter"
        ).value.toLowerCase();


    let jobs =
        document.querySelectorAll(
            "#jobList .job"
        );


    jobs.forEach(function(job){

        let text =
            job.innerText.toLowerCase();


        let jobSkill =
            job.dataset.skill
            ? job.dataset.skill.toLowerCase()
            : "";


        let jobLocation =
            job.dataset.location
            ? job.dataset.location.toLowerCase()
            : "";


        let searchMatch =
            text.includes(search);


        let skillMatch =
            skill === "" ||
            jobSkill === skill;


        let locationMatch =
            location === "" ||
            jobLocation.includes(location);


        if(
            searchMatch &&
            skillMatch &&
            locationMatch
        ){

            job.style.display = "block";

        }
        else{

            job.style.display = "none";

        }

    });

}


/* ================= LOGOUT ================= */

function logout(){

    let confirmLogout =
        confirm(
            "Are you sure you want to logout?"
        );


    if(confirmLogout){

        alert(
            "Logged out successfully!"
        );

        location.reload();

    }

}
/* =========================================
   WORKER MULTI PAGE NAVIGATION
========================================= */

function showPage(page, element) {

    const pages = {

        dashboard: "dashboard.html",

        registration: "registration.html",

        profile: "profile.html",

        documents: "documents.html",

        jobs: "jobs.html",

        applications: "applications.html",

        details: "job-details.html",

        availability: "availability.html",

        earnings: "earnings.html",

        payment: "payments.html",

        notifications: "notifications.html",

        rating: "feedback-rating.html"

    };


    if (pages[page]) {

        window.location.href = pages[page];

    }

}
