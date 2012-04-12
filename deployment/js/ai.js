var scorm = pipwerks.SCORM; // Seção SCORM
scorm.version = "2004"; // Versão da API SCORM

var memento = {};
var session = {};

$(document).ready(init); // Inicia a AI.

/*
 * Inicia a Atividade Interativa (AI)
 */
function init () {

  // Insere o filme Flash na página HTML
  // ATENÇÃO: os callbacks registrados via ExternalInterface no Main.swf levam algum tempo para ficarem disponíveis para o Javascript. Por isso não é possível chamá-los imediatamente após a inserção do filme Flash na página HTML.  
	var flashvars = {};
	flashvars.ai = "swf/AI-0148.swf";
	flashvars.width = "700";
	flashvars.height = "669";
	
	var params = {};
	params.menu = "false";
	params.scale = "noscale";

	var attributes = {};
	attributes.id = "ai";
	attributes.align = "middle";

	swfobject.embedSWF("swf/AI-0148.swf", "ai-container", flashvars.width, flashvars.height, "10.0.0", "expressInstall.swf", flashvars, params, attributes);
	
	memento = fetch();
}

function fetch() {
	var ans = {};
	ans.completed = false;
	ans.score = 0;
	ans.learner = "Fulano de tal";
	ans.ex1 = false;
	
	session.connected = scorm.init();
	session.standalone = !session.connected;
	
	if (session.standalone) {
		var stream = localStorage.getItem("AI-0148-memento");
		if (stream != null)
			ans = JSON.parse(stream);
	} else {
		var completionstatus = scorm.get("cmi.completion_status");
		switch (completionstatus) {
		case "not attempted":
		case "unknown":
		default:
			ans.learner = scorm.get("cmi.learner_name");
			break;
		case "incomplete":
			var stream = scorm.get("cmi.location");
			if (stream != "")
				ans = JSON.parse(stream);
			ans.learner = scorm.get("cmi.learner_name");
			break;
		case "completed":
			var stream = scorm.get("cmi.location");
			if (stream != "")
				ans = JSON.parse(stream);
			ans.learner = scorm.get("cmi.learner_name");
			break;
		}
	}
	return ans;
}

function save2LS(str) {
	localStorage.setItem("AI-0148-memento", str);
}

function getLocalStorageString() {
	var stream = localStorage.getItem("AI-0148-memento");
	return stream;
}