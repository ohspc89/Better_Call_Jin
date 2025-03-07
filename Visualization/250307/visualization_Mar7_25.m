%% Data visualization practice (March 7, 2025)
% `` will mark code snippets.
% ex) run `1+3`; `plot()` is a function to draw plots
%
% '' will indicate strings.


% Read the data
bwt = readtable('lowbwt.csv');

% Let's plot the data first
% Simple scatterplot - sbp (Y-axis) vs. gestational age (X-axis)?
% Let's use `scatter()` function.
% If you do not know what to give to this function,
% type `help scatter` in the Command Window and hit return. 
% Here we will try couple different options to use `scatter()`.
% For each item below, replace '...' with your answer.

% 1) scatter(X,Y) // X and Y are vectors.
%    What would you provide for X and Y?
%    (hint: if you want values of a column(col) from a table(tbl),
%     you use the command: `tbl.col`)
figure(1)
X=...
Y=...
scatter(X,Y)

% 1-2) An alternative way: `scatter(tbl, XVAR, YVAR)`
% where tbl is the table, XVAR is the variable on the X-axis
% and YVAR is the variable on the Y-axis.
scatter(bwt, 'gestage', 'sbp')

% 2) scatter(X,Y,SZ) // X and Y are vectors.
%    SZ is a scalar (all markers in one same size)
%    or a vector (different sizes).
%    Let's first set SZ=25.
figure(2)
sz = 25;
scatter(...)

%    Then set it to a vector
%    `repelem(V,N)` replicate elements of an array V
sz = repelem([65,45,85,165,105], 20);
figure(3)
scatter(...)

% 3) scatter(X,Y,SZ,C) // C is a string or an array
figure(4)
sz = 75;
% Assign "red" to a variable `colors`
colors = ;
scatter(...) % Don't forget to use `colors`.

% 4) Let's make C based on different categorical variable value
%    In MATLAB, you need to use for-loop.
%    Let's first define how long the `colors` vector should be
clength = ...;
%   a) sex: 'red' if 0, 'blue' otherwise.
%      There can be different ways, but let's make use of the fact
%      that sex has two levels: 0 and 1.
%      In fact, in many programming languages, 0 is the integer
%      value of False and 1 is the integer value of True.
%      So we will first create a color vector `colors`, 
%      whose elements are all red.
%      Then we will change values to "blue" where sex is 1.

% `repmat(A,M,N)` is commonly used to create an array by
% repeting the same value. A can be a string, a number, or a matrix.
% The function will create a large matrix of an M-by-N tiling of copies
% of A.
% ex. `repmat(3, 2, 1)` returns [3;3], a 2-by-1 matrix of {3}
% ex2. `repmat("hello", 1, 8)` returns ["hello", "hello", ..., "hello"],
% a 1-by-8 matrix of {'hello'}

% Here we will first prepare `colors`, a 1-by-{clength} array of "red".
colors = repmat("red", 1, clength);

% `find(X)` is a function that finds indices of nonzero elements.
% For example, `find([3, 0, 2, 0])` returns [1, 3].
% If the column 'sex' of the table 'bwt' is comprised of values 0 and 1,
% you can use `find()` to get the indices of sex==1.
% Previously, we planned to change values of the vector `colors`,
% defined above as a string array. Right now, all elements are "red".
% `colors(find(...)) = ...` is the command you need to run.
% Please fill in ...
colors(find(...)) = ...;

% Finally, plot the data indicating the sex difference
figure(5)
hold on
for i = 1:length(colors)
    scatter(X(i), Y(i), 65, colors(i))
end
hold off
legend('Female', 'Male')

%   b) Can you do the same thing with the 'grmhem' variable of the table?
%      This time, make colors to be "pink" for grmhem == 0
%      and "green" otherwise. Also, try adding 'filled' in your arguments.
%      ex. `scatter(...,'filled')`. See what happens.

% 5) We can use symbols instead of colors to indicate differences.
%    Let's use the apgar5 variable.
%    What's the distribution of ths variable?
hist(bwt.apgar5)
%    Let's use three symbols: '+', '^', and 'o'.
%    '+': if apgar5 value is less than 5
%    '^': if apgar5 value is 5 or 6
%    'o': if apgar5 value is greater than 6

% Let's start with preparing a template.
symbols = repmat(' ', 1, N);
% Then replace ' ' with the symbols using logical indexing
% similar to what we did when we created `colors`.
% Here are some practices that will help you with logical indexing.
% Suppose there's an array we will be referencing.
reference_arr = [2, 3, 4, 7];
% You have another array you want to modify, based on the values
% of `reference_arr`.
[nrow, ncol] = size(reference_arr);
toy_symbols = repmat(' ', 1, ncol);
% You want to have 'v' if the element of `reference_arr` is less than 3.
% First, see what this returns:
reference_arr < 3
% Then interpret what this line means
toy_symbols(reference_arr < 3) = 'v';
% You want to have '*' if the element is greater than or equal to 3 
% but less than or equal to 4.
toy_symbols(reference_arr>=3 & reference_arr <=4) = '*';
% Finally, you want to have '^' (Diamond shaped symbol) if
% the element is greater than 4.
toy_symbols(reference_arr>4) = '^';

% Can we plot these symbols?
y_ref = [3, 4, 5, 6];
hold on
for i=1:length(reference_arr)
    scatter(reference_arr(i), y_ref(i), 120, 'k', toy_symbols(i))
end
hold off
legend('ref < 3', '3 <= ref <= 4', 'ref > 4')
% Misc.
xlim([1, 8])
ylim([2, 7])
xlabel('Reference X')
ylabel('Reference Y')

% Now, let's finish task 5.