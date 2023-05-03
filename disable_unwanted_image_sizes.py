import os
import sys

wp_dir = sys.argv[1] # user-input wordpress directory. Default is C:\wamp64\www\wordpress

# 1. Modify threshold in wp-admin/includes/image.php to set it to zero.
fp1 = os.path.join(wp_dir,'wp-admin/includes/image.php')
f = open(fp1,'r')
wholeText = f.readlines() # read the entire text to memory as list of line strings
f.close()
f = open(fp1,'w') # overwrite it
for line in wholeText:
    if line.find('big_image_size_threshold') > -1:
        id_eq = line.find('=')
        line = line[0:id_eq+1] + ' 0;\n'
    f.write(line)
f.close()

# 2. Modify wp-includes/media.php
# Change defaultsize to empty array, and comment out all add_image_size() statement
fp2 = os.path.join(wp_dir,'wp-includes/media.php')
f = open(fp2,'r')
wholeText = f.readlines() # read the entire text to memory as list of line strings
f.close()
f = open(fp2,'w')
found_get_intermediate = False
modified_defaultsize = False
begin_add_additional = False
end_add_additional = False
for line in wholeText:
    # find and modify $defaultsize definition in get_intermediate function
    if not modified_defaultsize: # only do it once
        if found_get_intermediate:
            if line.find('$default_sizes') > -1:
                id_eq = line.find('=')
                line = line[0:id_eq+1] + ' array();\n'
                modified_defaultsize = True                    
        if line.find('function get_intermediate') > -1:
            found_get_intermediate = True # next line will be the target
    # find function _wp_add_additional and comment out all add_image_size() statement
    if not end_add_additional:
        if begin_add_additional:
            if line.find('add_image_size') > -1: # need to comment this line
                if not line[0:2]=='//': # not already commented
                    line = '//' + line
            if line.find('}') > -1: # end of _wp_add_additional function
                end_add_additional = True
        if line.find('_wp_add_additional') > -1:
            begin_add_additional = True
    f.write(line)
f.close()

# 3. Modify wp-content/plugins/woocommerce/includes/class-woocommerce.php
# Find "'woocommerce_single'," and comment that line
fp3 = os.path.join(wp_dir,'wp-content/plugins/woocommerce/includes/class-woocommerce.php')
f = open(fp3,'r')
wholeText = f.readlines() # read the entire text to memory as list of line strings
f.close()
f = open(fp3,'w') # overwrite it
for line in wholeText:
    if line.find("'woocommerce_single',") > -1:
        if not line[0:2]=='//': # not already commented
            line = '//' + line
    f.write(line)
f.close()