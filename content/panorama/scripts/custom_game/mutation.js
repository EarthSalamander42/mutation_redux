var mutation = [];

function Mutation(args) {
	$("#Mutations").style.visibility = "visible";

	if (args["positive"])
		mutation[1] = args["positive"];

	if (args["negative"])
		mutation[2] = args["negative"];

	if (args["terrain"])
		mutation[3] = args["terrain"];

	$("#Mutation1Label").text = $.Localize("#mutation_" + mutation[1]);
	$("#Mutation2Label").text = $.Localize("#mutation_" + mutation[2]);
	$("#Mutation3Label").text = $.Localize("#mutation_" + mutation[3]);

	for (var j = 1; j <= 3; j++) {
		SetMutationTooltip(j);
	}
}

(function () {
	var mutations = CustomNetTables.GetTableValue("game_options", "mutations");

	if (!mutations) {
		$.Msg("nil mutation args!")
		return;
	}

	Mutation(mutations);
})();
