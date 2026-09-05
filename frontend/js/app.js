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