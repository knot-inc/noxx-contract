pragma circom 2.0.3;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/comparators.circom";
include "./tree.circom";

template VerifyTalent(numOfFields, nLevels) {
    // Public inputs
    signal input commits[numOfFields];
    signal input age;

    // Private inputs: in the order of name, age, countryCode 
    signal input values[numOfFields];
    signal input nonces[numOfFields];

    // For inclusion check
    signal input pathIndices[nLevels];
    signal input siblings[nLevels];
    signal input leaf;
    signal input root;
    
    component hashers[numOfFields];
    for (var i = 0; i < numOfFields; i++) {
        hashers[i] = Poseidon(2);
        hashers[i].inputs[0] <== values[i];
        hashers[i].inputs[1] <== nonces[i];
        hashers[i].out === commits[i];
    }

    // CountryCode eligibility check
    component inclusionProof = MerkleTreeInclusionProof(nLevels);
    inclusionProof.leaf <== leaf;

    for (var i = 0; i < nLevels; i++) {
        inclusionProof.siblings[i] <== siblings[i];
        inclusionProof.pathIndices[i] <== pathIndices[i];
    }
    root === inclusionProof.root;

    // Age confirmation
    component ageGreaterEqThan = GreaterEqThan(32);
    ageGreaterEqThan.in[0] <== values[1];
    ageGreaterEqThan.in[1] <== age;

    ageGreaterEqThan.out === 1;

}

// We verify name, age and country eligibility
component main { public [ commits, age ] } = VerifyTalent(3, 8);

/* INPUT = {
    "commits": ["20199178195905961735016964499017101892030965751975447305563774106156390243229"],
    "values": ["5363620503418597221"],
    "nonces": ["825373492"]
} */