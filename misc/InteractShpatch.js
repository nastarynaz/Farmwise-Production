let lst = -1;
async function main() {
    const BASE_URL = "https://farmwise-be-prod.vercel.app";
    const trs = document.querySelectorAll(".requests_table tbody tr");
    if (trs.length != lst && trs[0].childNodes[2].innerText === "http") {
        lst = trs.length;
        const tr = trs[0];
        tr.childNodes[2].click();
        setTimeout(async () => {
            const url = document.querySelector(".token.request-target.url").innerText;
            if (!/^\/iots\//.test(url)) {
                return;
            }
            console.log("Sending!");
            const json = JSON.parse(document.querySelector(".token.application-json").innerText);
            const resp = await fetch(BASE_URL + url, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify(json),
            });
            console.log(await resp.json());
        }, 500);
    }

    requestAnimationFrame(main);
}

requestAnimationFrame(main);
