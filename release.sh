#!/bin/bash
# Automated GitHub Release Script with Changelog

set -e

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "Usage: ./release.sh v1.0.0"
    exit 1
fi

echo "🚀 Creating automated release $VERSION..."

# Ensure we're on main/master and up to date
git checkout main 2>/dev/null || git checkout master
git pull origin main 2>/dev/null || git pull origin master

# Validate version format
if [[ ! $VERSION =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "❌ Version must be in format v1.2.3"
    exit 1
fi

# Create and push tag (this will trigger the automated release workflow)
echo "📝 Creating tag $VERSION..."
git tag -a "$VERSION" -m "Release $VERSION"
git push origin "$VERSION"

REPO_URL=$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\/[^/.]*\).*/\1/')

echo ""
echo "✅ Tag $VERSION created and pushed!"
echo "🤖 GitHub Actions will now:"
echo "   1. Generate changelog from commits/PRs"
echo "   2. Create GitHub release with changelog"
echo "   3. Build multi-arch containers (AMD64/ARM64)"
echo "   4. Push to GitHub Container Registry"
echo "   5. Test container functionality"
echo ""
echo "📦 Container will be available at:"
echo "   - ghcr.io/$REPO_URL:$VERSION"
echo "   - ghcr.io/$REPO_URL:latest"
echo ""
echo "🔗 Monitor progress at:"
echo "   - Actions: https://github.com/$REPO_URL/actions"
echo "   - Release: https://github.com/$REPO_URL/releases/tag/$VERSION"
echo ""
echo "💡 Tip: Use conventional commits (feat:, fix:, docs:) for better changelogs!"
