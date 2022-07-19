pragma circom 2.0.3;

include "../node_modules/circomlib/circuits/poseidon.circom";

template VerifyTalent(numOfFields) {
    // Public inputs
    signal input commits[numOfFields];

    // Private inputs
    signal input values[numOfFields];
    signal input nonces[numOfFields];
    
    component hashers[numOfFields];
    for (var i = 0; i < numOfFields; i++) {
        hashers[i] = Poseidon(2);
        hashers[i].inputs[0] <== values[i];
        hashers[i].inputs[1] <== nonces[i];
        hashers[i].out === commits[i];
    }

    // Constraints should come after
}

component main { public [ commits ] } = VerifyTalent(1);

/* INPUT = {
    "commits": "20199178195905961735016964499017101892030965751975447305563774106156390243229",
    "values": ["5363620503418597221"],
    "nonces": ["825373492"]
} */