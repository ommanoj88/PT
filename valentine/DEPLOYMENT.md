# 💖 Valentine's Website - Free Deployment Guide

## 🚀 Option 1: GitHub Pages (Recommended - Completely Free!)

Your Valentine's website will be automatically deployed when changes are pushed to the `main` branch.

### Setup Steps:

1. **Go to your repository on GitHub** → `https://github.com/ommanoj88/PT`

2. **Enable GitHub Pages:**
   - Go to **Settings** → **Pages**
   - Under **Source**, select **GitHub Actions**
   - Click **Save**

3. **Merge this PR** (or push to main)

4. **Your site will be live at:**
   ```
   https://ommanoj88.github.io/PT/
   ```

5. **Share the link with Renata!** 💕

### How it works:
- A GitHub Actions workflow (`.github/workflows/deploy-valentine.yml`) automatically deploys the `valentine/` folder
- Every time you update the valentine page and push to `main`, it redeploys automatically
- **100% free** - GitHub Pages is free for public repositories!

---

## 🚀 Option 2: Netlify (Also Free!)

1. Go to [netlify.com](https://www.netlify.com/) and sign up with GitHub
2. Click **"Add new site"** → **"Import an existing project"**
3. Select your GitHub repo `ommanoj88/PT`
4. Set these build settings:
   - **Base directory:** `valentine`
   - **Build command:** (leave empty)
   - **Publish directory:** `valentine`
5. Click **Deploy**
6. Your site gets a free URL like `https://your-site-name.netlify.app`

---

## 🚀 Option 3: Vercel (Also Free!)

1. Go to [vercel.com](https://vercel.com/) and sign up with GitHub
2. Click **"New Project"** → Import your repo
3. Set **Root Directory** to `valentine`
4. Click **Deploy**
5. Your site gets a free URL like `https://your-project.vercel.app`

---

## 🚀 Option 4: Cloudflare Pages (Also Free!)

1. Go to [pages.cloudflare.com](https://pages.cloudflare.com/)
2. Connect your GitHub account
3. Select the repo
4. Set **Build output directory** to `valentine`
5. Deploy!

---

## 💡 Tips

- **Custom domain:** All these services support custom domains for free!
- **SSL/HTTPS:** All services provide free SSL certificates automatically
- **The site is a single HTML file** with no build step needed, making deployment super simple

## 🔗 Quick Share

Once deployed, you can share the link via:
- WhatsApp / Telegram message
- QR code (generate at qr-code-generator.com)
- Email

**Happy Valentine's Day! 💖🌹**
