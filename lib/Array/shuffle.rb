# Array/shuffle.rb
# Array#shuffle

# 20130922
# 0.3.0

# Description: Reorders an array randomly.

# Changes since 0.2:
# 1. Removed the aliases to their own files.

class Array

  def shuffle
    sort_by{rand}
  end

end
