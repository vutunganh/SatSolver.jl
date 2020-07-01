import Random

const RNG_SEED = 1234567
const rng = Random.MersenneTwister(RNG_SEED)

function rand_wrapper(args...)
  rand(rng, args...)
end

function gen_rand_clause(; max_variables::Unsigned, max_clause_len::Unsigned)::Clause
  clause_len = rand_wrapper(1:max_clause_len)
  clauses = [rand_wrapper((-1, 1)) * signed(rand_wrapper(1:max_variables)) for _ in 1:clause_len]
  Clause(clauses)
end

function gen_rand_formula(;
                          max_clauses::Unsigned,
                          max_variables::Unsigned,
                          max_clause_len::Unsigned)::Formula
  clause_cnt = rand_wrapper(1:max_clauses)
  Formula([gen_rand_clause(;
                           max_variables=max_variables,
                           max_clause_len=max_clause_len) for _ in 1:clause_cnt])
end
