<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NeoPay™ - Perfect Finance</title>
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
            background-color: var(--white);
            color: var(--primary);
            -webkit-font-smoothing: antialiased;
            overflow-x: hidden;
        }

        /* Reusable Classes */
        .container {
            max-width: 1100px;
            margin: 0 auto;
            padding: 0 24px;
        }
        
        .btn {
            display: inline-block;
            background-color: var(--primary);
            color: var(--white);
            padding: 12px 28px;
            border-radius: 9999px;
            text-decoration: none;
            font-weight: 500;
            font-size: 0.95rem;
            transition: var(--transition);
            border: 2px solid var(--primary);
            cursor: pointer;
        }
        
        .btn:hover {
            background-color: transparent;
            color: var(--primary);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }

        .btn-full {
            width: 100%;
            border-radius: 12px;
            padding: 16px;
        }

        /* Header */
        header {
            padding: 24px 0;
            position: sticky;
            top: 0;
            background-color: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(10px);
            z-index: 100;
        }

        .nav-wrapper {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .logo {
            font-weight: 700;
            font-size: 1.25rem;
            text-decoration: none;
            color: var(--primary);
            display: flex;
            align-items: center;
            gap: 4px;
        }

        .nav-links {
            display: flex;
            gap: 32px;
        }

        .nav-links a {
            text-decoration: none;
            color: var(--secondary);
            font-size: 0.95rem;
            transition: var(--transition);
            font-weight: 500;
        }

        .nav-links a:hover {
            color: var(--primary);
        }

        /* Hero */
        .hero {
            text-align: center;
            padding: 60px 0 60px;
        }

        .hero h1 {
            font-size: 4rem;
            font-weight: 700;
            line-height: 1.1;
            letter-spacing: -0.02em;
            margin-bottom: 24px;
        }

        .hero h1 span {
            color: var(--secondary);
            display: block;
            font-weight: 500;
        }

        .hero .btn-hero {
            margin-bottom: 64px;
            padding: 14px 32px;
        }

        .hero-media {
            width: 100%;
            margin: 0 auto;
            aspect-ratio: 16/9;
            background: linear-gradient(135deg, #F9FAFB, #E5E7EB);
            border-radius: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 16px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.03);
            transition: var(--transition);
        }

        .hero-media:hover {
            transform: scale(1.01);
            box-shadow: 0 20px 40px rgba(0,0,0,0.06);
        }

        .shape {
            width: 60px;
            height: 60px;
            background-color: var(--white);
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
        }

        .shape.square { border-radius: 4px; }
        .shape.circle { border-radius: 50%; }
        .shape.triangle {
            background-color: transparent;
            box-shadow: none;
            width: 0;
            height: 0;
            border-left: 35px solid transparent;
            border-right: 35px solid transparent;
            border-bottom: 60px solid var(--white);
            filter: drop-shadow(0 4px 12px rgba(0,0,0,0.05));
        }

        /* Trust & Stats */
        .trust-section {
            padding: 80px 0;
            text-align: center;
        }

        .trust-heading h2 {
            font-size: 1.8rem;
            font-weight: 700;
            margin-bottom: 8px;
            letter-spacing: -0.01em;
        }

        .trust-heading p {
            color: var(--secondary);
            font-size: 1.2rem;
            margin-bottom: 60px;
        }

        .stats {
            display: flex;
            justify-content: center;
            gap: 100px;
            margin-bottom: 80px;
        }

        .stat-item h3 {
            font-size: 3rem;
            font-weight: 700;
            margin-bottom: 8px;
            letter-spacing: -0.02em;
        }

        .stat-item p {
            color: var(--secondary);
            font-size: 0.9rem;
            font-weight: 500;
        }

        .partners {
            display: flex;
            justify-content: center;
            gap: 40px;
            flex-wrap: wrap;
            color: var(--secondary);
            font-weight: 500;
            font-size: 0.95rem;
        }

        .partner {
            display: flex;
            align-items: center;
            gap: 10px;
            transition: var(--transition);
            cursor: default;
        }

        .partner:hover {
            color: var(--primary);
            transform: translateY(-2px);
        }

        .partner-dot {
            width: 10px;
            height: 10px;
            background-color: #D1D5DB;
            transition: var(--transition);
        }
        
        .partner:hover .partner-dot {
            background-color: var(--primary);
        }

        .partner-square { border-radius: 2px; }
        .partner-circle { border-radius: 50%; }
        .partner-triangle { 
            width: 0; height: 0; background: none; 
            border-left: 5px solid transparent; border-right: 5px solid transparent; border-bottom: 10px solid #D1D5DB;
        }
        .partner:hover .partner-triangle {
            border-bottom-color: var(--primary);
            background-color: transparent;
        }

        /* Features */
        .features {
            padding: 40px 0 80px;
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
        }

        .feature-card {
            background-color: #F8F9FA;
            border-radius: 16px;
            padding: 70px 30px;
            text-align: center;
            transition: var(--transition);
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .feature-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 15px 30px rgba(0,0,0,0.04);
            background-color: #F3F4F6;
        }

        .feature-card .shape {
            width: 70px;
            height: 70px;
            margin-bottom: 40px;
        }
        
        .feature-card .shape.triangle {
            border-left: 40px solid transparent;
            border-right: 40px solid transparent;
            border-bottom: 70px solid var(--white);
        }

        .feature-card p {
            color: var(--secondary);
            font-size: 0.85rem;
            margin-bottom: 4px;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            font-weight: 600;
        }

        .feature-card h4 {
            font-size: 1.15rem;
            font-weight: 600;
            color: var(--primary);
        }

        /* Newsletter */
        .newsletter {
            padding: 60px 0 100px;
            text-align: center;
            max-width: 400px;
            margin: 0 auto;
        }

        .newsletter h2 {
            font-size: 1.8rem;
            font-weight: 700;
            margin-bottom: 8px;
            letter-spacing: -0.01em;
        }

        .newsletter p {
            color: var(--secondary);
            margin-bottom: 24px;
            font-size: 1.1rem;
        }

        .newsletter-form {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .newsletter-input {
            width: 100%;
            padding: 14px 20px;
            border-radius: 8px;
            border: 1px solid var(--border);
            background-color: #F8F9FA;
            font-size: 0.95rem;
            outline: none;
            transition: var(--transition);
            text-align: center;
        }

        .newsletter-input:focus {
            border-color: var(--secondary);
            background-color: var(--white);
        }

        .newsletter-btn {
            border-radius: 8px;
            padding: 14px;
            font-weight: 600;
            font-size: 0.95rem;
        }

        /* Footer */
        footer {
            padding: 60px 0 60px;
            border-top: 1px solid #F3F4F6;
        }

        .footer-content {
            display: flex;
            justify-content: space-between;
        }

        .footer-logo {
            display: flex;
            gap: 6px;
            align-items: flex-start;
        }
        
        .footer-logo .shape {
            width: 14px;
            height: 14px;
            box-shadow: none;
            background-color: #D1D5DB;
        }
        .footer-logo .shape.triangle {
            border-left: 7px solid transparent; border-right: 7px solid transparent; border-bottom: 14px solid #D1D5DB;
            background: none;
        }

        .footer-links {
            display: flex;
            gap: 80px;
        }

        .footer-column h5 {
            font-size: 0.8rem;
            margin-bottom: 20px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: var(--primary);
        }

        .footer-column ul {
            list-style: none;
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .footer-column a {
            color: var(--secondary);
            text-decoration: none;
            font-size: 0.9rem;
            transition: var(--transition);
        }

        .footer-column a:hover {
            color: var(--primary);
        }

        /* Responsive */
        @media (max-width: 992px) {
            .hero h1 { font-size: 3.5rem; }
            .stats { gap: 60px; }
            .features { padding: 40px 24px; gap: 16px; }
            .footer-links { gap: 40px; }
        }

        @media (max-width: 768px) {
            .nav-links { display: none; }
            .hero h1 { font-size: 2.5rem; }
            .stats { flex-direction: column; gap: 40px; margin-bottom: 60px; }
            .features { grid-template-columns: 1fr; }
            .footer-content { flex-direction: column; gap: 48px; }
            .footer-links { flex-wrap: wrap; gap: 40px; }
        }
    </style>
</head>
<body>

    <header>
        <div class="container nav-wrapper">
            <a href="/" class="logo">NeoPay™</a>
            <nav class="nav-links">
                <a href="#">About</a>
                <a href="#">Features</a>
                <a href="#">Pricing</a>
            </nav>
            <a href="#" class="btn">Get Started</a>
        </div>
    </header>

    <main>
        <!-- Hero Section -->
        <section class="hero container">
            <h1>Perfect Finance.<br><span>Learn More</span></h1>
            <a href="#" class="btn btn-hero">Get Started</a>
            
            <div class="hero-media">
                <div class="shape square"></div>
                <div class="shape circle"></div>
                <div class="shape triangle"></div>
            </div>
        </section>

        <!-- Trust Section -->
        <section class="trust-section container">
            <div class="trust-heading">
                <h2>10,000+ users trusted worldwide.</h2>
                <p>Experience premium banking designed for the future.</p>
            </div>
            
            <div class="stats">
                <div class="stat-item">
                    <h3>15+</h3>
                    <p>Years Experience</p>
                </div>
                <div class="stat-item">
                    <h3>250+</h3>
                    <p>Partners</p>
                </div>
            </div>

            <div class="partners">
                <div class="partner"><span class="partner-dot partner-square"></span> TechMedia</div>
                <div class="partner"><span class="partner-dot partner-circle"></span> FinancePro</div>
                <div class="partner"><span class="partner-dot partner-triangle"></span> Neobank</div>
                <div class="partner"><span class="partner-dot partner-square"></span> DesignGrid</div>
                <div class="partner"><span class="partner-dot partner-circle"></span> Investify</div>
            </div>
        </section>

        <!-- Features Section -->
        <section class="features container">
            <div class="feature-card">
                <div class="shape square"></div>
                <p>Security</p>
                <h4>Security Guarantee</h4>
            </div>
            <div class="feature-card">
                <div class="shape circle"></div>
                <p>Investing</p>
                <h4>Smart Investing</h4>
            </div>
            <div class="feature-card">
                <div class="shape triangle"></div>
                <p>Speed</p>
                <h4>Fast Transactions</h4>
            </div>
        </section>

        <!-- Newsletter Section -->
        <section class="newsletter container">
            <h2>Stay updated.</h2>
            <p>Subscribe for news.</p>
            
            <form class="newsletter-form" onsubmit="event.preventDefault();">
                <input type="email" placeholder="name@email.com" class="newsletter-input" required>
                <button type="submit" class="btn btn-full newsletter-btn">Subscribe Now</button>
            </form>
        </section>
    </main>

    <footer class="container">
        <div class="footer-content">
            <div class="footer-logo">
                <div class="shape square"></div>
                <div class="shape circle"></div>
                <div class="shape triangle"></div>
            </div>
            
            <div class="footer-links">
                <div class="footer-column">
                    <h5>About</h5>
                    <ul>
                        <li><a href="#">Company</a></li>
                        <li><a href="#">Careers</a></li>
                        <li><a href="#">Blog</a></li>
                    </ul>
                </div>
                <div class="footer-column">
                    <h5>Features</h5>
                    <ul>
                        <li><a href="#">Smart Investing</a></li>
                        <li><a href="#">Security</a></li>
                        <li><a href="#">Payments</a></li>
                    </ul>
                </div>
                <div class="footer-column">
                    <h5>Support</h5>
                    <ul>
                        <li><a href="#">Contact</a></li>
                        <li><a href="#">Help Center</a></li>
                        <li><a href="#">Terms</a></li>
                    </ul>
                </div>
            </div>
        </div>
    </footer>

</body>
</html>
