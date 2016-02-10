function [table,matrix,chi2,p,labels,nDeg] = raw2contingency(X, IVnames)

    nIVs = size(X,2)-1;
    DVlevels = unique(X(:,end));
    nDVlevels = length(DVlevels);
    
    
    if nargin < 2 || isempty(IVnames)
        IVnames = strread(sprintf('IV%i\n',1:nIVs),'%s','delimiter','\n');
    end
    
    IVs = cell(1, nIVs);
    for i = 1:nIVs
        IVs{i} = unique(X(:,i));
    end
    nIVLevels = cellfun(@length,IVs);
    totalnIVlevels = sum(nIVLevels);
    
    %% 
    
    XX = num2cell(X,1);
    [matrix,chi2,p,labels] = crosstab(XX{:});
    nIVs = size(XX,2)-1;
    matrix = reshape(permute(matrix,[nIVs:-1:1 nIVs+1]),[2^nIVs 2]); % reshape into contingency table

    % overwrite p vals since the crosstab chi2 stat does NOT use the Yates
    % correction factor when v = 1
    % also in crosstab when v > 1, v is caluclated as being slightly great (e.g. for
    % [2 2 2] DV == 4 rather than 3 [I guess this is since here we are
    % always collapsing the matrix into 2 dimensions]
 	[p, chi2, nDeg] = contTabChi2(matrix);

     
    %% Construct formatted table
    table = cell(totalnIVlevels+2, nIVs+nDVlevels);
    
    table{1,end} = 'DV';
    table(2, 1:nIVs) = IVnames;
    table(2, (nIVs+1):end) = strread(sprintf('%1.2f\n',DVlevels),'%s','delimiter','\n');

    % tabulate into continency table
    switch nIVs
        case 1
            m = 3;
            for i = 1:nIVLevels(1)
                table{m,1} = IVs{1}(i);

                idx = X(:,1) == IVs{1}(i);
                DV = X(idx,2);
                for d = 1:nDVlevels
                    table{m,nIVs+d} = sum(DV==DVlevels(d));
                end

                m = m + 1;
            end
        case 2
            m = 3;
            for i = 1:nIVLevels(1)
                table{m,1} = IVs{1}(i);
                for j = 1:nIVLevels(2)
                    table{m,2} = IVs{2}(j);
                    
                    idx = X(:,1) == IVs{1}(i) & X(:,2) == IVs{2}(j);
                    DV = X(idx,3);
                    for d = 1:nDVlevels
                        table{m,nIVs+d} = sum(DV==DVlevels(d));
                    end

                    m = m + 1;
                end
            end
        case 3
            m = 3;
            for i = 1:nIVLevels(1)
                table{m,1} = IVs{1}(i);
                for j = 1:nIVLevels(2)
                    table{m,2} = IVs{2}(j);
                    for k = 1:nIVLevels(3)
                        table{m,3} = IVs{3}(k);

                        idx = X(:,1) == IVs{1}(i) & X(:,2) == IVs{2}(j) & X(:,3) == IVs{3}(k);
                        DV = X(idx,4);
                        for d = 1:nDVlevels
                            table{m,nIVs+d} = sum(DV==DVlevels(d));
                        end

                        m = m + 1;
                    end
                end
            end
        otherwise
            warning('a:b','functionality not yet written. No formatted table returned');
    end

    
    
end