<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login - NeoPay™</title>
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #000000;
            --secondary: #6B7280;
            --bg-light: #F3F4F6;
            --white: #FFFFFF;
            --border: #E5E7EB;
            --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Inter', sans-serif;
        }

        body {
            background-color: var(--bg-light);
            color: var(--primary);
            -webkit-font-smoothing: antialiased;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px;
        }

        .login-wrapper {
            background-color: var(--white);
            border-radius: 24px;
            padding: 48px;
            width: 100%;
            max-width: 440px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.03);
            text-align: center;
            position: relative;
        }

        .logo {
            font-weight: 700;
            font-size: 1.5rem;
            text-decoration: none;
            color: var(--primary);
            display: inline-flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 32px;
        }

        .shape-logo {
            display: flex;
            gap: 4px;
            align-items: flex-end;
        }

        .shape {
            background-color: var(--primary);
        }

        .shape.square { width: 12px; height: 12px; border-radius: 2px; }
        .shape.circle { width: 12px; height: 12px; border-radius: 50%; }
        .shape.triangle {
            width: 0; height: 0; background: none;
            border-left: 6px solid transparent; border-right: 6px solid transparent; border-bottom: 12px solid var(--primary);
        }

        .login-heading h1 {
            font-size: 1.8rem;
            font-weight: 700;
            margin-bottom: 8px;
            letter-spacing: -0.01em;
        }

        .login-heading p {
            color: var(--secondary);
            font-size: 0.95rem;
            margin-bottom: 32px;
        }

        .form-group {
            margin-bottom: 20px;
            text-align: left;
        }

        .form-group label {
            display: block;
            font-size: 0.85rem;
            font-weight: 600;
            margin-bottom: 8px;
            color: var(--primary);
        }

        .form-control {
            width: 100%;
            padding: 14px 16px;
            border-radius: 12px;
            border: 1px solid var(--border);
            background-color: #F8F9FA;
            font-size: 0.95rem;
            outline: none;
            transition: var(--transition);
        }

        .form-control:focus {
            border-color: var(--primary);
            background-color: var(--white);
            box-shadow: 0 0 0 4px rgba(0,0,0,0.05);
        }

        .btn {
            display: inline-block;
            background-color: var(--primary);
            color: var(--white);
            padding: 14px 28px;
            border-radius: 9999px;
            text-decoration: none;
            font-weight: 500;
            font-size: 0.95rem;
            transition: var(--transition);
            border: 2px solid var(--primary);
            cursor: pointer;
            width: 100%;
            margin-top: 12px;
        }
        
        .btn:hover {
            background-color: transparent;
            color: var(--primary);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }

        .options {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
            font-size: 0.85rem;
        }

        .remember-me {
            display: flex;
            align-items: center;
            gap: 8px;
            color: var(--secondary);
            cursor: pointer;
        }

        .error-message {
            color: #EF4444;
            font-size: 0.85rem;
            margin-top: 6px;
        }

        .back-home {
            position: absolute;
            top: 24px;
            left: 24px;
            color: var(--secondary);
            text-decoration: none;
            font-size: 0.9rem;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: var(--transition);
        }

        .back-home:hover {
            color: var(--primary);
        }

        .admin-badge {
            background-color: var(--bg-light);
            color: var(--secondary);
            font-size: 0.75rem;
            font-weight: 600;
            padding: 4px 10px;
            border-radius: 999px;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin-bottom: 16px;
            display: inline-block;
        }
        
        /* Responsive */
        @media (max-width: 500px) {
            .login-wrapper {
                padding: 40px 24px;
            }
            .back-home {
                top: -30px;
                left: 0;
            }
        }
    </style>
</head>
<body>

    <div class="login-wrapper">
        <a href="/" class="back-home">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <line x1="19" y1="12" x2="5" y2="12"></line>
                <polyline points="12 19 5 12 12 5"></polyline>
            </svg>
            Home
        </a>

        <a href="/" class="logo">
            <div class="shape-logo">
                <div class="shape square"></div>
                <div class="shape circle"></div>
                <div class="shape triangle"></div>
            </div>
            NeoPay™
        </a>

        <div class="login-heading">
            <div class="admin-badge">Admin Portal</div>
            <h1>Welcome back.</h1>
            <p>Enter your details to access the dashboard.</p>
        </div>

        <form method="POST" action="{{ route('login') }}">
            @csrf
            
            <div class="form-group">
                <label for="email">Email Address</label>
                <input type="email" id="email" name="email" class="form-control" value="{{ old('email') }}" placeholder="name@email.com" required autofocus>
                @error('email')
                    <div class="error-message">{{ $message }}</div>
                @enderror
            </div>

            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" class="form-control" placeholder="••••••••" required>
            </div>

            <div class="options">
                <label class="remember-me">
                    <input type="checkbox" name="remember">
                    <span>Remember me</span>
                </label>
            </div>

            <button type="submit" class="btn">Sign In</button>
        </form>
    </div>

</body>
</html>
