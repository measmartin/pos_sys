export interface CreateUnitDto {
  unitName: string;
  unitCode: string;
  description?: string | null;
}

export interface UpdateUnitDto {
  unitName?: string | null;
  unitCode?: string | null;
  description?: string | null;
  isActive?: boolean | null;
}

export interface UnitDetailsDto {
  unitId: number;
  unitName: string;
  unitCode: string;
  description?: string | null;
  isActive: boolean;
  createdAt: string;
  updatedAt?: string | null;
}

export interface UnitPagedResponseDto {
  data: UnitDetailsDto[];
  page: number;
  pageSize: number;
  totalCount: number;
}
