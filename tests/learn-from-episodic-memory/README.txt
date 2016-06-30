Tests from 3 onwards are cumulative i.e. their test set-ups are identical 
but the amount of processing performed by the "learn-or-reinforce-productions"
procedure differs in each test:

- Test 3: Episode 1 processed
- Test 4: Episode 2 processed
- Test 5: Episode 3 and action sequence processed
- Test 6: Action sequence learned as production

Therefore, in test 6, episodes 1, 2 and 3 are processed and the action sequence
derived from the episodes is learned and used to create a production.  
Consequently, checks performed in previous tests are not repeated in subsequent
ones.