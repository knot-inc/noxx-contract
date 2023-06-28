use dep::std;

fn main(
    values: [Field; 3], // private inputs, in the order of name, age, countrycode
    nonces: [Field; 3],
    commits: pub [Field; 3], // commitments, in the order of name, age, countrycode
    age: pub Field,
//   leaf: Field, 
//   root: Field, 
//   index: Field,
//   siblings: [Field; 8],
) {
    // Check commitment which consist of name and nonce from Poseidon hash
    for i in 0..3 {
        assert(commits[i] == std::hash::poseidon::bn254::hash_2([values[i], nonces[i]]));
    }
    
    // Age confirmation
    assert(age as u32 <= values[1] as u32);

    // CountryCode eligibility check
    // let new_root = std::merkle::compute_root_from_leaf(leaf, index, siblings);
    // constrain new_root == root;
    // new_root
}

#[test]
fn test_main() {
    main([5363620503418597221,20,19024], [825373492,825373492,825373492],[20199178195905961735016964499017101892030965751975447305563774106156390243229,8819208578747443403144689107172414148408385498253978002562079324362344755523,3998228618412097657774020135623673392269184037010946178179137544382082909182],18);
}
