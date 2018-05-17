var mutation = [];

function Mutation(args) {
	$("#Mutations").style.visibility = "visible";

	$.Msg("Mutation JS:")
	$.Msg(args["positive"])
	$.Msg(args["negative"])
	$.Msg(args["terrain"])

	mutation[1] = args["positive"]
	mutation[2] = args["negative"]
	mutation[3] = args["terrain"]

	$("#Mutation1Label").text = $.Localize("mutation_" + mutation[1]);
	$("#Mutation2Label").text = $.Localize("mutation_" + mutation[2]);
	$("#Mutation3Label").text = $.Localize("mutation_" + mutation[3]);

	for (var j = 1; j <= 3; j++) {
		SetMutationTooltip(j)
	}
}

function SetMutationTooltip(j) {
	var panel = $("#Mutation" + j)

	panel.SetPanelEvent("onmouseover", function () {
		$.DispatchEvent("UIShowTextTooltip", panel, $.Localize("mutation_" + mutation[j] + "_Description"));
	})

	panel.SetPanelEvent("onmouseout", function () {
		$.DispatchEvent("UIHideTextTooltip", panel);
	})
}

(function () {
	GameEvents.Subscribe("send_mutations", Mutation);
})();
