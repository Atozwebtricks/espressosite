// Vendor utilities for extracting names from domains and handling simplified vendor format

export function extractVendorName(url: string): string {
  try {
    const domain = new URL(url).hostname.toLowerCase();
    
    // Remove www. prefix
    const cleanDomain = domain.replace(/^www\./, '');
    
    // Domain to vendor name mapping
    const vendorMap: Record<string, string> = {
      'amazon.com': 'Amazon',
      'amazon.co.uk': 'Amazon UK',
      'amazon.ca': 'Amazon Canada',
      'amazon.de': 'Amazon Germany',
      'williams-sonoma.com': 'Williams Sonoma',
      'seattlecoffeegear.com': 'Seattle Coffee Gear',
      'clivecoffee.com': 'Clive Coffee',
      'wholelattelove.com': 'Whole Latte Love',
      'espressooutlet.com': 'Espresso Outlet',
      'lamarzocco.com': 'La Marzocco',
      'bedbathandbeyond.com': 'Bed Bath & Beyond',
      'target.com': 'Target',
      'walmart.com': 'Walmart',
      'bestbuy.com': 'Best Buy',
      'surlatable.com': 'Sur La Table',
      'crateandbarrel.com': 'Crate & Barrel',
      'wayfair.com': 'Wayfair',
      'coffeefool.com': 'Coffee Fool',
      'sweetmarias.com': "Sweet Maria's",
      'bluebottlecoffee.com': 'Blue Bottle Coffee',
      'intelligentsia.com': 'Intelligentsia',
      'stumptowncoffee.com': 'Stumptown Coffee',
      'counterculturecoffee.com': 'Counter Culture Coffee'
    };

    // Check if we have a specific mapping
    if (vendorMap[cleanDomain]) {
      return vendorMap[cleanDomain];
    }

    // For unknown domains, create a readable name from the domain
    const parts = cleanDomain.split('.');
    const mainPart = parts[0];
    
    // Convert camelCase or kebab-case to readable format
    const readable = mainPart
      .replace(/([a-z])([A-Z])/g, '$1 $2') // camelCase
      .replace(/[-_]/g, ' ') // kebab-case or snake_case
      .split(' ')
      .map(word => word.charAt(0).toUpperCase() + word.slice(1))
      .join(' ');
    
    return readable;
  } catch (error) {
    console.error('Error extracting vendor name from URL:', url, error);
    return 'Unknown Vendor';
  }
}

export function formatPrice(price: number | null | undefined): string {
  if (!price || price === 0) return '';
  return `$${price.toLocaleString()}`;
}

export function normalizeVendors(vendors: any[]): Array<{url: string, name: string, price?: number}> {
  if (!vendors || !Array.isArray(vendors)) return [];
  
  return vendors.map(vendor => {
    // Handle both old format and new simplified format
    if (typeof vendor === 'string') {
      // Simple URL string
      return {
        url: vendor,
        name: extractVendorName(vendor)
      };
    } else if (vendor && typeof vendor === 'object') {
      // Object format
      const url = vendor.url || vendor;
      const price = vendor.price;
      
      return {
        url: url,
        name: vendor.name || extractVendorName(url),
        price: price
      };
    }
    
    return {
      url: '',
      name: 'Invalid Vendor',
      price: 0
    };
  });
} 