function [Y,index] = Shuffle(X, dim, index, independentCols)
% [Y,index] = Shuffle(X, dim, index)
%
% Randomly sorts X.
% If X is a vector, sorts all of X, so Y = X(index).
% If X is an m-by-n matrix, sorts each column of X, so
%	for j=1:n, Y(:,j)=X(index(:,j),j).
%
% Also see SORT, Sample, Randi, and RandSample.

% xx/xx/92  dhb  Wrote it.
% 10/25/93  dhb  Return index.
% 5/25/96   dgp  Made consistent with sort and "for i=Shuffle(1:10)"
% 6/29/96	  dgp  Edited comments above.
% 5/18/02   dhb  Modified code to do what comments say, for matrices.
% 6/2/02    dhb  Fixed bug introduced 5/18.
% 
% PJ 29/3/2012 allows user to specify shuffle indices (useful when trying
% to sort within each column independently)
%
% !!!!NOTE: EACH COLUMN IS SHUFFLED INDEPENDENTLY
%
% EXAMPLE:
% design = repmat(1:5,[10,1,2])
% shuffle2(design,2)

if nargin < 2 || isempty(dim)
    dim = 1;
end

if dim == 2
%     X = X';
    X = permute(X,[2 1 3]);
end

if nargin< 3 || isempty(index)
    [null,index] = sort(rand(size(X)));
    if nargin >= 4 && ~independentCols
        index = repmat(index(:,1),1,size(index,2)); % same index for each
    end
end

[n,m] = size(X);
Y = zeros(size(X));
if (n == 1 | m == 1)
	Y = X(index);
else
	for j = 1:m
		Y(:,j)  = X(index(:,j),j);
	end
end
 
if dim == 2
%     Y = Y';
    Y = permute(Y,[2 1 3]);
end