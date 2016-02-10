function x = sortmat(x, j)
% sort matrix in ascending order based on column j

error('use sortrows');
    [~,idx] = sort(x(:,j));
    x = x(idx,:);
    
end