function payload = mpReadJson(path)
% Decode UTF-8 JSON bytes without platform-dependent character conversion.
% R2023b fileread/fread('*char') can replace supplementary Unicode on Windows.
fid = fopen(path,'rb');
if fid == -1
    error('matlab_sci_plot:JSONReadFailed','Cannot open JSON input: %s',string(path));
end
cleanup = onCleanup(@() fclose(fid));
bytes = fread(fid,Inf,'*uint8')';
payload = jsondecode(native2unicode(bytes,'UTF-8'));
end
