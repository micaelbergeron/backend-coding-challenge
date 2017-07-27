# Coveo Backend Coding Challenge
(inspired by https://github.com/busbud/coding-challenge-backend-c)

## Requirements

Design an API endpoint that provides auto-complete suggestions for large cities.

- The endpoint is exposed at `/suggestions`
- The partial (or complete) search term is passed as a querystring parameter `q`
- The caller's location can optionally be supplied via querystring parameters `latitude` and `longitude` to help improve relative scores
- The endpoint returns a JSON response with an array of scored suggested matches
    - The suggestions are sorted by descending score
    - Each suggestion has a score between 0 and 1 (inclusive) indicating confidence in the suggestion (1 is most confident)
    - Each suggestion has a name which can be used to disambiguate between similarly named locations
    - Each suggestion has a latitude and longitude

## "The rules"

- *You can use the language and technology of your choosing.* It's OK to try something new (tell us if you do), but feel free to use something you're comfortable with. We don't care if you use something we don't; the goal here is not to validate your knowledge of a particular technology.
- End result should be deployed on a public Cloud (Heroku, AWS etc. all have free tiers you can use).

## References

- Geonames provides city lists Canada and the USA http://download.geonames.org/export/dump/readme.txt

## Approach

The search engine uses a multi-layered approach to try to solve this problem. It actually consists of three layers:

  - Prefix: try to match the longest contiguous prefix
  - BKTree: match N edit-distance (to support small typos)
  - Geo: match using a search radius upon the location
  
Each matcher will return a score, that will be weighted and normalized. You may find the scores in the `score_components` attribute. Engines may skip for inputs they don't find useful.

### Caveats 

It doesn't support diacritics naturally (i.e. québec != quebec)

My levenshtein-damerau algorithm seems to have problem with the permutation, but it doesn't affect results that much.

## Author

Micael Bergeron <micaelbergeron@gmail.com>
