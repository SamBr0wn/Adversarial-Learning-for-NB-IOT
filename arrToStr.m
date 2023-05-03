function output = arrToStr(arr)

output = "[";
for i = 1:length(arr)
    output = output + string(arr(i));
    if i < length(arr)
        output = output + ", ";
    end
end
output = output + "]";

end