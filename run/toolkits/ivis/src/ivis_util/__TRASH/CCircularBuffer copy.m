classdef CCircularBuffer < handle
% circular-buffer (or: 'ring buffer') data-structure.
%
% n.b., does not like row vectors!
% n.b., 'put' is around 1.2300e-05 seconds slower than a version that
% returns NaNs even when no elements have been inserted previously
%
% CCircularBuffer Methods:
%   * CCircularBuffer	- Constructor
%   * put               - Add data row(s)
%   * get               - Get (n) rows (first-in first-out)
%   * clear             - reset counters and set all elements to NaN
%
% See Also:
%   none
%
% Example:
%   none
%
% Author:
%   Pete R Jones <petejonze@gmail.com>
%
% Verinfo:
%   1.0 PJ 03/2013 : first_build\n
%
% Todo:
%
% Copyright 2014 : P R Jones
% *********************************************************************
% 

    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================
    
    properties (Access = private)
        buffer
        nFreeElements
        i = 0;
    end
    
    properties (GetAccess = public, SetAccess = private)
        capacity % potential n data rows
        dims
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================

    methods (Access = public)
        
        function obj = CCircularBuffer(m, n)
            if nargin < 2 || isempty(n)
                n = 1;
            end
            
            obj.capacity = m;
            obj.buffer =  nan(m,n);
            obj.dims = [m,n];
            obj.nFreeElements = obj.capacity;
        end
        
        function out = put(obj, x)
            inputLength = size(x,1);
            
            if inputLength > obj.capacity % prevent overflow
                in = x(end-(obj.capacity-1):end, :);
                out = [obj.buffer(1:(obj.capacity-obj.nFreeElements), :); x(1:end-obj.capacity, :)];
            else
                in = [obj.buffer((inputLength+1):end, :); x]; % first in first out
                out = obj.buffer(1:(inputLength-obj.nFreeElements), :);
            end
            
            % set
            obj.buffer = in;
            obj.nFreeElements = max(0, obj.nFreeElements-inputLength);
        end
        
        function x = get(obj, n)
            if nargin < 2 || isempty(n)
                x = obj.buffer(1:end-obj.nFreeElements);
            else
                x = obj.buffer(1:n, :);
            end
        end
        
        
        
        function out = put2(obj, x)
            inputLength = size(x,1);
            
            idx = mod((1:inputLength)-1+obj.i,obj.capacity)+1;
            
            if nargout % only compute if output has been requested
                out = [obj.buffer(idx(1:min(obj.capacity, inputLength-max(obj.capacity-obj.i,0))), :); x((1:inputLength)<=(inputLength-obj.capacity),:)];
            end
            
            % set
            obj.buffer(idx,:) = x;
            obj.i = obj.i + inputLength;
        end
        
        function out = get2(obj, n)
            if nargin < 2 || isempty(n)
                n = obj.capacity;
            end
            out = obj.buffer(mod((1:n)-1+obj.i,obj.capacity)+1, :);
        end
        
        
        
        function [] = clear(obj)
            obj.nFreeElements = obj.capacity;
            obj.buffer(:,:) = NaN;
            obj.i = 0;
        end
    end
    
    
 	%% ====================================================================
    %  -----STATIC METHODS (public)-----
    %$ ====================================================================    
    
     methods (Static, Access = public)
         
         function [] = speedTest()
             N = 10000;
             
             
             
             fprintf('2 ---------------------\n\n');
             x = CCircularBuffer(10);
             x.put2(1);
             
             tic();
             for j = 1:N
                 x.put2(j);
             end
             toc()
             
             tic();
             for j = 1:N
                 x.put2((1:20)');
             end
             toc()
             
             tic();
             for j = 1:N
                 x.get2();
             end
             toc()
             
             tic();
             for j = 1:N
                 x.get2(4);
             end
             toc()
             
            
             
             fprintf('1 ---------------------\n\n');
             x = CCircularBuffer(10);
             x.put(1);
             
             tic();
             for j = 1:N
                 x.put(j);
             end
             toc()
             
             tic();
             for j = 1:N
                 x.put((1:20)');
             end
             toc()
             
             
             tic();
             for j = 1:N
                 x.get();
             end
             toc()
             
             tic();
             for j = 1:N
                 x.get(4);
             end
             toc()
             
             
             
         end
             
         % Unit tests -----------------------------------------------------
         function [] = unitTests()
             suite = testSuiteFromStatic('CCircularBuffer');
             suite.run(VerboseTestRunDisplay(1));
         end
         function [] = testVector()
             x = CCircularBuffer(10);
             assertEqual(x.capacity, 10);
             
             out = x.put([1 2 3]');
             assertTrue(isempty(out));
             
             out = x.put((4:10)');
             assertTrue(isempty(out));
             
             out = x.put(11);
             assertEqual(out, 1, 'Should return the first element to be overwritten')
             
             
 



             assertEqual(x.get(), (2:11)')
             
             assertEqual(x.get(1), 2, 'Should return the oldest element') 
             
             x.clear()
             assertTrue(isempty(x.get()));
             
%              assertTrue(isempty(x.get(3)));

x.clear()
out = x.put2([1 2 3]')
 assertTrue(isempty(out));

 out = x.put2((4:10)')
 assertTrue(isempty(out));

 out = x.put2(11)
 assertEqual(out, 1, 'Should return the first element to be overwritten')
 
 
             dfdf
             
         end
         function [] = testMatrix()
             x = CCircularBuffer(10,3);
             assertEqual(x.capacity, 10)
         end
     end
    
    
end
