fn = dir('2\')
fn = {fn(~[fn.isdir]).name}

for i = 1:length(fn)
     editMetaData('acuity',sprintf('2\\%s',fn{i}),'Session ID',fn{i}(10))
end
