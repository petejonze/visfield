classdef CList < handle
%
% See also CStack
%
% copyright: zhangzq@citics.com, 2010.
% url: http://zhiqiang.org/blog/tag/matlab

    properties (Access = private)
        buffer      %
        beg         %
        len         %
    end
    
    properties (Access = public)
        capacity    %
    end
    
    methods
        function obj = CList(c)
            if nargin >= 1 && iscell(c)
                obj.buffer = [c(:); cell(numel(c), 1)];
                obj.beg = 1;
                obj.len = numel(c);
                obj.capacity = 2*numel(c);
            elseif nargin >= 1
                obj.buffer = cell(100, 1);
                obj.buffer{1} = c;
                obj.beg = 1;
                obj.len = 1;
                obj.capacity = 100;                
            else
                obj.buffer = cell(100, 1);
                obj.capacity = 100;
                obj.beg = 1;
                obj.len = 0;
            end
        end
        
        function s = size(obj)
            s = obj.len;
        end
        
        function b = empty(obj)  %
            b = (obj.len == 0);
        end
        
        function pushtorear(obj, el) %
            obj.addcapacity();
            if obj.beg + obj.len  <= obj.capacity
                obj.buffer{obj.beg+obj.len} = el;
            else
                obj.buffer{obj.beg+obj.len-obj.capacity} = el;
            end
            obj.len = obj.len + 1;
        end
        
        function pushtofront(obj, el) %
            obj.addcapacity();
            obj.beg = obj.beg - 1;
            if obj.beg == 0
                obj.beg = obj.capacity; 
            end
            obj.buffer{obj.beg} = el;
            obj.len = obj.len + 1;
        end
        
        function el = popfront(obj) %
            el = obj.buffer(obj.beg);
            obj.beg = obj.beg + 1;
            obj.len = obj.len - 1;
            if obj.beg > obj.capacity
                obj.beg = 1;
            end
        end
        
        function el = poprear(obj) %
            tmp = obj.beg + obj.len;
            if tmp > obj.capacity
                tmp = tmp - obj.capacity;
            end
            el = obj.buffer(tmp);
            obj.len = obj.len - 1;
        end
        
        function el = front(obj) %
            try
                el = obj.buffer{obj.beg};
            catch ME
                throw(ME.messenge);
            end
        end
        
        function el = back(obj) %
            try
                tmp = obj.beg + obj.len - 1;
                if tmp >= obj.capacity, tmp = tmp - obj.capacity; end;
                el = obj.buffer(tmp);
            catch ME
                throw(ME.messenge);
            end            
        end
        
        function el = top(obj) %
            try
                tmp = obj.beg + obj.len - 1;
                if tmp >= obj.capacity, tmp = tmp - obj.capacity; end;
                el = obj.buffer(tmp);
            catch ME
                throw(ME.messenge);
            end            
        end
        
        function removeall(obj) %
            obj.len = 0;
            obj.beg = 1;
        end
        
        
        function remove(obj, k)
            if nargin == 1
                obj.len = 0;
                obj.beg = 1;
            else % k ~= 0
                id = obj.getindex(k);

                obj.buffer{id} = [];
                obj.len = obj.len - 1;
                obj.capacity = obj.capacity - 1;

                
                if id < obj.beg
                    obj.beg = obj.beg - 1;
                end
            end
        end
        
        
        function add(obj, el, k)
            obj.addcapacity();
            id = obj.getindex(k);
            
            if k > 0
                obj.buffer = [obj.buffer(1:id-1); el; obj.buffer(id:end)];
                if id < obj.beg
                    obj.beg = obj.beg + 1;
                end
            else
                obj.buffer = [obj.buffer(1:id); el; obj.buffer(id:end)];
                if id < obj.beg
                    obj.beg = obj.beg + 1;
                end
            end
        end
        
        function display(obj)
            if obj.size()
                rear = obj.beg + obj.len - 1;
                if rear <= obj.capacity
                    for i = obj.beg : rear
                        disp([num2str(i - obj.beg + 1) '-th element of the stack:']);
                        disp(obj.buffer{i});
                    end
                else
                    for i = obj.beg : obj.capacity
                        disp([num2str(i - obj.beg + 1) '-th element of the stack:']);
                        disp(obj.buffer{i});
                    end     
                    for i = 1 : rear
                        disp([num2str(i + obj.capacity - obj.beg + 1) '-th element of the stack:']);
                        disp(obj.buffer{i});
                    end
                end
            else
                disp('The queue is empty');
            end
        end
        
        
        function c = content(obj)
            rear = obj.beg + obj.len - 1;
            if rear <= obj.capacity
                c = obj.buffer(obj.beg:rear);                    
            else
                c = obj.buffer([obj.beg:obj.capacity 1:rear]);
            end
        end
        
        function c = toarray(obj)
            c = obj.content();
        end
    end
    
    
    
    methods (Access = private)
        
        function id = getindex(obj, k)
            if k > 0
                id = obj.beg + k;
            else
                id = obj.beg + obj.len + k;
            end     
            
            if id > obj.capacity
                id = id - obj.capacity;
            end
        end
        
        function addcapacity(obj)
            if obj.len >= obj.capacity - 1
                sz = obj.len;
                if obj.beg + sz - 1 <= obj.capacity
                    obj.buffer(1:sz) = obj.buffer(obj.beg:obj.beg+sz-1);                    
                else
                    obj.buffer(1:sz) = obj.buffer([obj.beg:obj.capacity, ...
                        1:sz-(obj.capacity-obj.beg+1)]);
                end
                obj.buffer(sz+1:obj.capacity*2) = cell(obj.capacity*2-sz, 1);
                obj.capacity = 2*obj.capacity;
                obj.beg = 1;
            end
        end
    end % private methos
    
    methods (Abstract)
        
    end
end
