#!/usr/bin/env bash
sed -i '' "s@ => @=>@g" lib/main.dart
sed -i '' "s@ : @:@g" lib/main.dart
sed -i '' "s@ + @+@g" lib/main.dart
sed -i '' "s@ - @-@g" lib/main.dart
sed -i '' "s@ \* @*@g" lib/main.dart
sed -i '' "s@ / @/@g" lib/main.dart
sed -i '' "s@ \|\| @\|\|@g" lib/main.dart
sed -i '' "s@ \&\& @\&\&@g" lib/main.dart
sed -i '' "s@: @:@g" lib/main.dart
sed -i '' "s@ = @=@g" lib/main.dart
sed -i '' "s@, @,@g" lib/main.dart
sed -i '' "s@) @)@g" lib/main.dart
sed -i '' "s@ (@(@g" lib/main.dart
sed -i '' "s@ > @>@g" lib/main.dart
sed -i '' "s@ < @<@g" lib/main.dart
sed -i '' "s@ \*= @\*=@g" lib/main.dart
sed -i '' "s@ {@{@g" lib/main.dart
sed -i '' "s@import @import@g" lib/main.dart
sed -i '' "s@? @?@g" lib/main.dart
sed -i '' "s@ ?@?@g" lib/main.dart
sed -i '' "s@ =@=@g" lib/main.dart
sed -i '' "s@= @=@g" lib/main.dart
sed -i '' "s@More:@More: @g" lib/main.dart

# [ ]{2,}
# @override\n @override
# \n
