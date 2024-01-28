module Verfiers
    def verify_password(password)
        if password.length < 8
            return "Password must be at least 8 characters long"
        end
        if password =~ /[A-Z]/
            return "Password must contain at least one uppercase letter"
        end
        if password =~ /[a-z]/
            return "Password must contain at least one lowercase letter"
        end
        if password =~ /[0-9]/
            return "Password must contain at least one number"
        end
        return nil
    end
end