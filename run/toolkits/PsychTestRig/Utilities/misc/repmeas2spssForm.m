function [y,headers]=repmeas2spssForm(x)

    nIVs = size(x,2)-2;

    DV = x(:,1);
    IV1 = unique(x(:,2));
    if nIVs == 1
        pid = unique(x(:,3));
        
        y = []; headers = {};
        for i = 1:length(pid)
            row = [];
            for j = 1:length(IV1)
                    idx = x(:,2)==IV1(j) & x(:,3)==pid(i);
                    row(end+1) = DV(idx); %#ok
                    if i==1
                        headers{end+1} = sprintf('A%i',j); %#ok
                    end
            end
            
            % add row
            y(i,:) = row; %#ok
        end
    elseif nIVs == 2
        IV2 = unique(x(:,3));
        pid = unique(x(:,4));
        
        y = []; headers = {};
        for i = 1:length(pid)
            row = [];
            for j = 1:length(IV1)
                for k = 1:length(IV2)
                    idx = x(:,2)==IV1(j) & x(:,3)==IV2(k) & x(:,4)==pid(i);
                    row(end+1) = DV(idx); %#ok
                    if i==1
                        headers{end+1} = sprintf('A%i_B%i',j,k); %#ok
                    end
                end
            end
            
            % add row
            y(i,:) = row; %#ok
        end
    else
        error('a:b','n IVs not supported yet due to the fact this is all pretty dodgy code');
    end
    
   

end

% function [y,headers]=repmeas2spssForm(x)
% 
%     pid = unique(x(:,4));
%     IV1 = unique(x(:,2));
%     IV2 = unique(x(:,3));
%     
%     y = []; headers = {};
%     for i = 1:length(pid)
%         row = [];
%         
%         for j = 1:length(IV1)
%             for k = 1:length(IV2)
%                 idx = x(:,2)==IV1(j) & x(:,3)==IV1(k) & x(:,4)==pid(i);
%                 row(end+1) = x(idx,1); %#ok
%                 if i==1
%                     headers{end+1} = sprintf('A%i_B%i',j,k); %#ok
%                 end
%             end
%         end
%         
%         % add row
%         y(i,:) = row; %#ok
%     end
% 
% end