i want to learn how db works 


Let's try to implement a db without any knowledge of how a db works
 
first im gonna try to implement on my own 
a Key value db 

then a SQL



// Key val 

metadata file 
bin files 


// first design of the storage engine
in header key plus start end bytes index 


what the setter func needs to do 

padd the key
getthedb file size + 1 => start of the value stored 
write to header => the key(8bytes) (start) (len) or (end)
then write value to dbfile


what the getter needs to do:

iterate over header files 
=> find the proper Key 
=> get start end 
open dbfile to start end toget the value



