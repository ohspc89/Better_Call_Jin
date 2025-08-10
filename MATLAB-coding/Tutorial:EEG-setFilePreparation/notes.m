%% A note on cellfun
% `A = cellfun(FUN, C, ..., 'Param1', val1, ...)` applies the function
% specified by FUN to the contents of each cell of cell array C, and
% returns the results in the array A, with optional parameter settings.
% FUN is a function handle to a function that takes one input argument
% and returns a scalar value.

% Here, 'FUN' is '@(x) str2double(regexp(x, '\d+', 'match', 'once'))'
% This is called a 'function handle'. You can read more from
% mathworks.com/help/matlab/function-handles.html
% but think of it as a tool to **customize** a pre-defined function,
% or **facilitate** the use of your custom-defined function.
% Also, to not blow your head, consider its form to be always:
%   '@(x) some_function(x, ...)'
% where '...' indicates optional parameters.

%% Example 1a
% Let's start with a simple example. `cellArray` is a 1x5 cell array.
% Read more about it from here: matworks.com/help/matlab/ref/cell.html
cellArray = {'1', '2', '3', '4', '5'};

% What if you want to make all 5 characters to numbers?
% `str2double(x)` is a function that converts text to numeric array.
% The **text** still needs to be numbers, such as '32'.
% ex. `str2double('32')` >> 32
% ex. `str2double('hello')` >> NaN

% So you apply `str2double(x)` to `cellArray` using `cellfun`.
% Remember, the format is `cellfun(FUN, C, ...)` where FUN is a function
% handle in the form of `@(x) some_function(x, ...)`.
% 'some_function' in this scenario is `str2double(x)`. Therefore,
% `@(x) str2double(x)` is the right form of FUN
numericArray = cellfun(@(x) str2double(x), cellArray);

%% Example 1b
% To help your understanding, here's another example.
% Let's now switch over - convert numbers to characters.
cellArray2 = {1, 2, 3, 4, 5};

% You need to use `num2str(x)`.
charArray = cellfun(@(x) num2str(x), cellArray2);

%% Function handle - Advanced
% In Ran's code, he had other parameters in `str2double(x)`:
%   `Sess_trialIdx = cellfun(@(x) str2double(regexp(x, '\d+', 'match', 'once')),...`
% So he's using another function, `regexp(str, expression, outkey, option)`
% inside `str2double(x)`. Let's dig down.

% `regexp(str, expression)` is the simplest use of the function.
% This returns the starting index of each substring of **str**
% that matches the character patterns specified by the regular expression.
% In Ran's code, the regular expression is '\d+', which means a series of
% 'd'igits. 
% 
% For example `regexp('3abe', '\d+')` will return 1. '3' is the first (1)
% character of the entire character array, '3abe'.
% `regexp('3203abe', '\d+')` will also return 1. Can you guess why?
% What about `regexp('3abc23', '\d+')`? This returns [1, 5].

% `regexp(str, expression, outkey, option)` is a more mouthful use.
% **outkey** is a keyword that indicates which outputs to return.
% `regexp('3203abe', '\d+', 'match')` will return '3203',
% which is the segment of **str** '3203abe' that matchs the **expression**.
% If so, what would `regexp('32d30-db112', '\d+', 'match')` would return?

% Finally, **option** is a keyword that determines the search option.
% 'once' will return the first element of the output of 
% `regexp(str, expression, outkey)`.
% Therefore, `regexp('TD50_Mon3_Basdeline.fdt', '\d+', 'match', 'once')`
% will return '50'.

% Ok. Back to Ran's code:
% `Sess_trialIdx = cellfun(@(x) str2double(regexp(x, '\d+', 'match', 'once')),...`
% We now know that `regexp(x, ...)` will return a character, because
% **option** is 'once'. `str2double(x)` will work as expected.

%% `cellfun` - Advanced
% Ran's code has the second part of `cellfun`:
% `Sess_trialIdx = cellfun(@(x) str2double(...), {SessionDir.name}, ...
%       'UniformOutput', false);

% Remember, the correct use of `cellfun` is 
%   `cellfun(FUN, C, ..., 'Param1', 'val1', ...)`
% Here, `{SessionDir.name}` is the value of 'C' parameter.
% `SessionDir` is a struct with a field named 'name'.
% What was `SessionDir` again? It's the output of the `dir(foldername)`.
% Assuming the following hierarchy:
% .
% |-- SampleData
% |   |-- TD08
% |   |   |-- Mon1
% |   |   |   |-- TD08_Mon1_Baseline.set
% |   |   |   |-- TD08_Mon1_reach.set

% `dir('./SampleData/TD08/Mon1/*.set')` will return a 2-by-1 structure
% because there are two .set files in './SampleData/TD08/Mon1/'

% (You can also refer to 'EEGWISE-commentary.pdf', availble in 
%  the GitHub repository: ohspc89/Better_Call_Jin/MATLAB-coding)

% Hang in there. So you apply `FUN` to `C`.
% Basically, `FUN` will convert the string that match the pattern
% defined by `regexp` to a number. `C` is a cell array.
% That is why `{SessionDir.name}` is provided as the value of `C`.

% Elements of `{SessionDir.name}` are:
%   {'TD08_Mon1_Baseline.set'}, {'TD08_Mon1_reach.set'}, ...
% Then applying FUN will return: [8, 8]

% Lastly, the parameter 'UniformOutput' and its value, false, are
% used to make `cellfun` return a cell array.
% I erased them, because Ran's next line is nullifying the effect anyways.