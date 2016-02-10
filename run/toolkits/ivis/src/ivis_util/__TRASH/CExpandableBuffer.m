% clear all; x = CExpandableBuffer(5, 2, 2); x.put([1 2]); x.put([3 4]); x.put([5 6]); x.put(rand(6,2));
% x.buffer
% x.get
% x.get(1:5,1)
% x.getLastN(6,1)
% x.clear
% x.get
classdef CExpandableBuffer < handle

    properties (Constant)
        DEFAULT_EXPANSION_FACTOR = 2;
    end
    properties (GetAccess = public, SetAccess = private)
        n
        m
        expansionFactor
        buffer
        counter = 1
    end
    
    methods
        function obj = CExpandableBuffer(n, m, expansionFactor)
            if nargin < 3 || isempty(expansionFactor)
                expansionFactor = CExpandableBuffer.DEFAULT_EXPANSION_FACTOR;
            end
            
            obj.n = n;
            obj.m = m;
            obj.expansionFactor = expansionFactor;
            obj.buffer =  nan(n,m);
        end
        
        function [] = put(obj, x)
            i = obj.counter; % start idx
            ii = i + size(x,1) - 1; % stop idx
            %
            obj.buffer(i:ii,:) = x;
            %
            obj.counter = ii+1;
            %
            % grow by expansion factor if within 10% of end
            if (ii/obj.n) > 0.9
                newN = floor(obj.n * obj.expansionFactor);
                obj.buffer = [obj.buffer; nan(newN-obj.n, obj.m)];
                fprintf('Growing data store... (%i -> %i)\n',obj.n,newN);
                obj.n = newN;
            end
        end
        
        function y = getLastN(obj,n,mi)
            if nargin < 2 || isempty(n)
                error('a:b','c');
            end
            if nargin < 3 || isempty(mi)
                mi = 1:obj.m; % for selecting specific columns (defaults to all)
            end
            
            ii = obj.counter - 1; % start idx
            i = ii - (n-1); % stop idx
            i = max(1,i); % prevent out of bounds
            %
            y = obj.buffer(i:ii, mi);
        end
        
        function y = get(obj,ni,mi)
            if nargin < 2 || isempty(ni)
                ii = obj.counter - 1; % start idx
                i = ii - (obj.n-1); % stop idx
                i = max(1,i); % prevent out of bounds
                ni = i:ii;
            end
            if nargin < 3 || isempty(mi)
                mi = 1:obj.m; % for selecting specific columns
            end
            
            y = obj.buffer(ni, mi);
        end

        % will this start to die as the n points increases?
        function y = getBeforeEach(obj,A,testCol,mi)
            if nargin < 3 || isempty(mi)
                mi = 1:obj.m; % for selecting specific columns
            end
            
            % For each element of A, find the nearest smaller-or-equal value in B:
            B = obj.buffer(:,testCol);           
            [~,ib] = histc(A, [-inf; B; inf]);
            y = obj.buffer(ib-1,mi);
        end

        function y = getAfterX(obj,X,testCol,mi)
            if nargin < 3 || isempty(mi)
                mi = 1:obj.m; % for selecting specific columns
            end
            y = obj.buffer(obj.buffer(:,testCol)>X,mi);
        end
        function y = getEqualX(obj,X,testCol)
            y = obj.buffer(obj.buffer(:,testCol)==X,:);
        end
        
        function [] = clear(obj)
            obj.buffer(:,:) = NaN;
            obj.counter = 1;
        end
        
        function n = getNElements(obj)
            n = obj.counter;
        end
        
    end
end
