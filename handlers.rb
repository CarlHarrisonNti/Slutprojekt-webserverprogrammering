module Verfiers
    def verify_password(password)
        result = {"Password be at least 8 characters long" => true,
                  "Password contain at least one uppercase letter" => true,
                  "Password contain at least one lowercase letter" => true,
                  "Password contain at least one number" => true}
        if password.length < 8
            result["Password be at least 8 characters long"] = false
        end
        unless password =~ /[A-Z]/
            result["Password contain at least one uppercase letter"] = false
        end
        unless password =~ /[a-z]/
            result["Password contain at least one lowercase letter"] = false
        end
        unless password =~ /[0-9]/
            result["Password contain at least one number"] = false
        end
        result = result.sort_by {|key, value| [value ? 0 : 1, key]}.to_h
        return result
    end
end
