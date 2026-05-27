export interface CreateCustomerDto {
  customerName?: string | null;
  phoneNumber?: string | null;
  email?: string | null;
  location?: string | null;
  city?: string | null;
  country?: string | null;
  notes?: string | null;
}

export interface UpdateCustomerDto {
  customerName?: string | null;
  phoneNumber?: string | null;
  email?: string | null;
  location?: string | null;
  city?: string | null;
  country?: string | null;
  notes?: string | null;
  isActive?: boolean | null;
}

export interface CustomerDetailsDto {
  customerId: number;
  customerName?: string | null;
  phoneNumber?: string | null;
  email?: string | null;
  location?: string | null;
  city?: string | null;
  country?: string | null;
  notes?: string | null;
  isActive: boolean;
  createdAt: string;
  updatedAt?: string | null;
}

export interface CustomerPagedResponseDto {
  data: CustomerDetailsDto[];
  page: number;
  pageSize: number;
  totalCount: number;
}
