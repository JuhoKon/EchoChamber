// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// Bring in Phoenix channels client library:
import {Socket} from "phoenix";

// And connect to the path in "lib/echochamber_web/endpoint.ex". We pass the
// token for authentication. Read below how it should be used.
let socket = new Socket("/socket", {params: {token: window.userToken}});

let channel           = socket.channel("room:lobby", {});
let chatInput         = document.querySelector("#chat-input");
let messagesContainer = document.querySelector("#messages");

chatInput.addEventListener("keypress", event => {
    console.log("Event");
    if(event.key === 'Enter'){
                channel.push("new_msg", {body: chatInput.value});
        chatInput.value = "";
    }
});

channel.on("new_msg", payload => {
    let messageItem = document.createElement("p");
    messageItem.innerText = `[${Date()}] ${payload.body}`;
    messagesContainer.appendChild(messageItem);
});

channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp); })
    .receive("error", resp => { console.log("Unable to join", resp); });

socket.connect();

export default socket;


