export interface CreateCurrencyDto {
  currencyCode: string;
  currencyName: string;
  currencySymbol?: string | null;
  exchangeRate?: number;
  isBaseCurrency?: boolean;
}

export interface UpdateCurrencyDto {
  currencyCode?: string | null;
  currencyName?: string | null;
  currencySymbol?: string | null;
  exchangeRate?: number | null;
  isBaseCurrency?: boolean | null;
  isActive?: boolean | null;
}

export interface CurrencyDetailsDto {
  currencyId: number;
  currencyCode: string;
  currencyName: string;
  currencySymbol?: string | null;
  exchangeRate: number;
  isBaseCurrency: boolean;
  isActive: boolean;
  createdAt: string;
  updatedAt?: string | null;
}

export interface CurrencyPagedResponseDto {
  data: CurrencyDetailsDto[];
  page: number;
  pageSize: number;
  totalCount: number;
}
